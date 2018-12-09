# coding: utf-8
class Handicap < ApplicationRecord
  has_many :teams
  scope :srs_keelboat, -> { where(type: 'SrsKeelboat')}
  scope :srs_multihull, -> { where(type: 'SrsMultihull')}
  scope :srs_dingy, -> { where(type: 'SrsDingy')}
  scope :srs_certificate, -> { where(type: 'SrsCertificate')}
  scope :srs_multihull_certificate, -> { where(type: 'SrsMultihullCertificate')}
  scope :sxk_certificate, -> { where(type: 'SxkCertificate')}
  scope :legacy_boat_type, -> { where(type: 'LegacyBoatType')}
  scope :active, -> { where("best_before IS ? OR best_before > ?",
                            nil, DateTime.now)}

  # The column 'name' is boat_type_name.
  # The column 'best_before' is expired_at; i.e., it is set when the
  # handicap has been expired (detected during import).
  #
  # For all certificates, the 'registry_id' is the unique identifier.
  # For non-certificates, the 'name' (boat type name) is the unique identifier.
  # This gives the invariant: (type, registry_id, name, best_before) is unique.

  default_scope { order 'name', 'sail_number' }

  def description
    "#{self.name}, SRS: #{self.srs}, SXK: #{self.sxk}, #{self.source}"
  end

  def self.types
    types = {}
    types['SrsKeelboat'] = 'Enskrovsbåt enligt SRS-tabellen'
    types['SrsMultihull'] = 'Flerskrovsbåt enligt SRS-tabellen'
    types['SrsDingy'] = 'Jolle enligt SRS-tabellen'
    types['SrsCertificate'] = 'SRS-mätbrev enskrov (för individuell båt)'
    types['SrsMultihullCertificate'] = 'SRS-mätbrev flerskrov (för individuell båt)'
    types['SoonSrsCertificate'] = 'Kommer att skaffa SRS-mätbrev'
    types['SxkCertificate'] = 'SXK-mätbrev (för individuell båt)'
    types['SoonSxkCertificate'] = 'Kommer att skaffa SXK-mätbrev'

    types
  end

  def self.short_types
    types = {}
    types['SrsKeelboat'] = 'SRS Enskrov'
    types['SrsMultihull'] = 'SRS Flerskrov'
    types['SrsDingy'] = 'SRS Jolle'
    types['SrsCertificate'] = 'SRS-mätbrev enskrov'
    types['SrsMultihullCertificate'] = 'SRS-mätbrev flerskrov'
    types['SoonSrsCertificate'] = 'Interimistiskt'
    types['SxkCertificate'] = 'SXK-mätbrev'
    types['SoonSxkCertificate'] = 'Interimistiskt'

    types
  end

  def self.import(type, source, external_system, handicaps, dryrun=false)
    yesterday = DateTime.now.in_time_zone.end_of_day - 1.day
    # keep track of all active handicaps
    cur_handicaps = Hash.new
    for h in Handicap.where(
               "type = :type and best_before IS :best_before",
               {type: type, best_before: nil})
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
      # check if a current handicap exists
      if isCert
        cur = Handicap.find_by(type: type,
                               registry_id: h[:registry_id],
                               best_before: nil)
      else
        cur = Handicap.find_by(type: type,
                               name: h[:name],
                               best_before: nil)
      end
      cur_handicaps.delete(cur.id) unless cur.nil?
      if not cur.nil? and cur.sxk != sxk
        puts "Changed rating: handicap #{cur.description} (#{cur.id})"
        # we found an existing handicap that has a new sxk rating.
        # we need to mark it as obsolete, and check if there are any
        # active teams that use this handicap.  these teams need to set
        # a new handicap.
        Team.handicap_changed(cur.id, dryrun)
        cur.best_before = yesterday
        cur.save! unless dryrun
      end
      if cur.nil? or cur.sxk != sxk
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
        puts "Add handicap: #{newh.description}"
        newh.save! unless dryrun
      end
    end
    # cur_handicaps now contains handicaps that need to be removed
    for cur_id in cur_handicaps
      cur = Handicap.find(cur_id[0])
      puts "Remove: handicap #{cur.description} (#{cur.id})"
      Team.handicap_changed(cur.id, dryrun)
      cur.best_before = yesterday
      cur.save! unless dryrun
    end
  end

end
