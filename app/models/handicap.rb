# coding: utf-8
class Handicap < ApplicationRecord
  has_many :teams
  scope :srs_keelboat, -> { where(type: 'SrsKeelboat')}
  scope :srs_multihull, -> { where(type: 'SrsMultihull')}
  scope :srs_dingy, -> { where(type: 'SrsDingy')}
  scope :srs_certificate, -> { where(type: 'SrsCertificate')}
  scope :srs_multihull_certificate, -> { where(type: 'SrsMultihullCertificate')}
  scope :sxk_certificate, -> { where(type: 'SxkCertificate')}
  scope :active, -> { where("expired_at IS ?", nil)}

  # The column 'name' is boat_type_name.
  #
  # For all certificates, the 'registry_id' is the unique identifier.
  # For non-certificates, the 'name' (boat type name) is the unique identifier.
  # This gives the invariant: (type, registry_id, name, expired_at) is unique.

  default_scope { order 'name', 'sail_number' }

  def description
    if not self.expired_at.nil?
      exp = "Utgått #{self.expired_at} - "
    else
      exp = ""
    end
    "#{exp}#{self.name}, SRS: #{self.srs}, SXK: #{self.sxk}, #{Handicap.short_types[self.type]}"
  end

  def short_description
    if not self.expired_at.nil?
      exp = "Utgått #{self.expired_at} - "
    else
      exp = ""
    end
    "#{exp}#{self.name}, SRS: #{self.srs}, SXK: #{self.sxk}"
  end

  def self.types
    types = {}
    types['SxkCertificate'] = 'SXK-mätbrev (för individuell båt)'
    types['SrsCertificate'] = 'SRS-mätbrev enskrov (för individuell båt)'
    types['SrsMultihullCertificate'] = 'SRS-mätbrev flerskrov (för individuell båt)'
    types['SrsKeelboat'] = 'Enskrovsbåt enligt SRS-tabellen'
    types['SrsMultihull'] = 'Flerskrovsbåt enligt SRS-tabellen'
    types['SrsDingy'] = 'Jolle enligt SRS-tabellen'
    types['SoonSrsCertificate'] = 'Kommer att skaffa SRS-mätbrev'
    types['SoonSxkCertificate'] = 'Kommer att skaffa SXK-mätbrev'

    types
  end

  def self.short_types
    types = {}
    types['SxkCertificate'] = 'SXK-mätbrev'
    types['SrsCertificate'] = 'SRS-mätbrev enskrov'
    types['SrsMultihullCertificate'] = 'SRS-mätbrev flerskrov'
    types['SrsKeelboat'] = 'SRS enskrov'
    types['SrsMultihull'] = 'SRS flerskrov'
    types['SrsDingy'] = 'SRS jolle'
    types['SoonSrsCertificate'] = 'Interimistiskt'
    types['SoonSxkCertificate'] = 'Interimistiskt'

    types
  end

  def self.import(type, source, external_system, handicaps, user, dryrun=false)
    yesterday = DateTime.now.in_time_zone.end_of_day - 1.day
    # keep track of all active handicaps
    cur_handicaps = Hash.new
    for h in Handicap.active.where("type = ?", type)
      cur_handicaps[h.id] = true
    end
    isCert = (type == 'SrsCertificate' ||
              type == 'SrsMultihullCertificate' ||
              type == 'SxkCertificate')
    for h in handicaps
      srs = h[:srs]
      if not srs.nil?
        sxk = (srs * 1.22).round(2)
      else
        sxk = h[:sxk]
      end
      # safety check
      if !(sxk > 0)
        if isCert
          id = h[:registry_id]
        else
          id = h[:name]
        end
        puts "Handicap #{id} has sxk #{sxk}, ignoring"
        next
      end
      # check if a current handicap exists
      if isCert
        cur = Handicap.find_by(type: type,
                               registry_id: h[:registry_id],
                               expired_at: nil)
      else
        cur = Handicap.find_by(type: type,
                               name: h[:name],
                               expired_at: nil)
      end
      is_new = cur.nil?
      is_expired = (not h[:expired_at].nil?)
      has_changed = (not is_new and
                     (cur.sxk != sxk or (not srs.nil? and cur.srs != srs)))

      cur_handicaps.delete(cur.id) unless cur.nil?

      if is_new and is_expired
        # skip expired handicaps that we don't have as current
        next
      end

      if not(is_new) and (has_changed or is_expired)
        # we found an existing handicap that has a new sxk rating, or
        # has expired.
        # we need to mark it as expired, and check if there are any
        # active teams that use this handicap.  these teams need to set
        # a new handicap.
        if has_changed
          puts "Changed rating to #{sxk}: #{cur.description} (#{cur.id})"
        else
          puts "Expired handicap: #{cur.description} (#{cur.id})"
        end
        Team.handicap_changed(cur.id, dryrun)
        if not is_expired
          cur.expired_at = yesterday
        else
          cur.expired_at = h[:expired_at]
        end
        cur.save! unless dryrun
      end
      # we need to create a new handicap if this is new and not expired,
      # or if this is a changed existing and not expired.
      if (is_new or has_changed) and not(is_expired)
        case type
        when 'SrsKeelboat'
          newh = SrsKeelboat.new
        when 'SrsMultihull'
          newh = SrsMultihull.new
        when 'SrsDingy'
          newh = SrsDingy.new
        when 'SrsCertificate'
          newh = SrsCertificate.new
        when 'SrsMultihullCertificate'
          newh = SrsMultihullCertificate.new
        when 'SxkCertificate'
          newh = SxkCertificate.new
        end
        newh.srs = srs
        newh.sxk = sxk
        newh.source = source
        newh.external_system = external_system
        newh.registry_id = h[:registry_id]
        newh.name = h[:name]
        newh.owner_name = h[:owner_name]
        newh.boat_name = h[:boat_name]
        newh.sail_number = h[:sail_number]
        newh.expired_at = h[:expired_at]
        puts "Add handicap: #{newh.description}"
        newh.save! unless dryrun
      end
    end
    # cur_handicaps now contains handicaps that need to be expired
    for cur_id in cur_handicaps
      cur = Handicap.find(cur_id[0])
      puts "Remove: handicap #{cur.description} (#{cur.id})"
      Team.handicap_changed(cur.id, dryrun)
      cur.expired_at = yesterday
      cur.save! unless dryrun
    end
  end

end
