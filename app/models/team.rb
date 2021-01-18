class Team < ApplicationRecord
  belongs_to :race
  belongs_to :boat
  has_many :crew_members, dependent: :destroy
  has_many :logs
  has_many :people, :through => :crew_members
  has_many :non_skipper_crew_member, -> { where(skipper: false) }, class_name: 'CrewMember'
  has_many :seamen, :through => :non_skipper_crew_member, :source => :person
  has_one :skipper_crew_member, -> { where(skipper: true) }, class_name: 'CrewMember'
  has_one :skipper, :through => :skipper_crew_member, :source => :person
  belongs_to :handicap
  has_many :notes

  scope :from_race, ->(r_id) {joins(:race).where("races.id = ?", r_id) }
  scope :from_boat, ->(b_id) {joins(:boat).where("boats.id = ?", b_id) }
  scope :has_person, ->(p_id) {joins(:people).where("people.id = ?", p_id) }
  #scope :did_not_start, ->(value = true) { where(did_not_start: value) }
  #scope :did_not_finish, ->(value = true) { where(did_not_finish: value) }
  #scope :has_paid_fee, ->(value = true) { where(paid_fee: value) }
  scope :from_regatta, ->(r_id) { joins(race: :regatta).where("regattas.id = ?", r_id) }
  scope :is_active, ->(b = true) { joins(race: :regatta).where("regattas.active = ?", b) }

  accepts_nested_attributes_for :boat

  after_initialize :set_defaults, unless: :persisted?

  # the value 'closed' is manually set on teams that participated
  # while the review process in Giona was not implemented.  it means
  # that the data for the team is not complete; e.g., it might not
  # have a proper log book and result.
  enum state: [:draft, :submitted, :approved, :signed, :reviewed, :archived, :closed]
  enum sailing_state: [:not_started, :did_not_start, :started, :did_not_finish, :finished]

  after_initialize :set_default_state, :if => :new_record?

  delegate :minimal, to: :race
  delegate :period, to: :race

  def self.is_visible value = true
    if value == true
      where "state > ?", 0
    else
      where state: 0
    end
  end

  # we treat both 'archived' and 'closed' as archived
  def self.is_archived value = true
    if value
      where "state >= ?", 5
    else
      where "state < ?", 5
    end
  end

  def state_to_s
    str = Hash.new
    str['draft'] = 'utkast'
    str['submitted'] = 'inskickad'
    str['approved'] = 'godkänd'
    str['signed'] = 'signerad'
    str['reviewed'] = 'granskad'
    str['archived'] = 'arkiverad'
    str['closed'] = 'stängd'
    str[self.state]
  end

  def sxk
    if self.handicap.present?
      if self.handicap.sxk.present?
        self.handicap.sxk
      else
        2.0
      end
    else
      2.0
    end
  end

  def regatta_id
    self.race.regatta_id
  end

  def from_same_regatta
    race.regatta.teams
  end

  def set_defaults
    set_name
  end

  def set_name
    if (self.name.blank? || self.name.include?('/'))
      self.name = "#{self.skipper.try :last_name} / #{self.boat_name}"
    end
  end

  def set_boat boat
    self.boat_name = boat.try :name
    self.boat_type_name = boat.try :boat_type_name
    self.boat_sail_number = boat.try :sail_number
  end

  def set_skipper person
    crew_skipper = self.skipper_crew_member
    unless crew_skipper.nil?
      crew_skipper.skipper = false
      crew_skipper.save!
    end
    new_skipper = CrewMember.find_by team_id: self.id, person_id: person.id
    new_skipper.skipper = true
    new_skipper.save!
  end

  def self.handicap_changed(handicap_id, user, dryrun=false)
    for t in Team.is_archived(false)
               .where("handicap_id = ?", handicap_id)
               .joins(race: :regatta).where("regattas.active = ?", true)
      puts "Team #{t.id} uses changed handicap and needs to pick new handicap"
      t.do_handicap_changed(user) unless dryrun
    end
  end

  def do_handicap_changed user
    # PRE: called only when self.handcap_id refers to an obsolete handicap
    reset_handicap = false
    send_email = false
    send_officer_email = false
    case self.state
    when nil, "draft"
      reset_handicap = true
      send_email = true
    when "submitted"
      self.state = :draft
      reset_handicap = true
      send_email = true
    when "approved"
      self.state = :submitted
      send_email = true
      reset_handicap = true
    when "reviewed"
      send_officer_email = true
      reset_handicap = true
    end
    if reset_handicap
      Note.create(team_id: self.id,
                  user: user,
                  description: "Det valda handikappet (#{self.handicap_id}) är utgånget och har därför nollställts.")
      self.handicap_id = nil
      self.handicap_type = nil
      self.save!
      if send_email
        TeamMailer.handicap_reset_email(self).deliver
      end
      if send_officer_email
        TeamMailer.handicap_reset_officer_email(self).deliver
      end
    end
  end

  def review
    review_status = Hash.new

    # race_details
    if self.start_point.blank?
      review_status['race_details'] = 'Var vill du starta? '
    end
    if self.offshore.nil?
      review_status['race_details'] = "#{review_status['race_details'].to_s} Seglar du havssträckor eller bara kuststräckor?"
    end

    #crew
    if self.people.blank?
      review_status['crew'] = 'Lägg till minst en i besättning.'
    else
      if self.skipper.blank?
        review_status['crew'] = 'Vem ska vara skeppare?'
      else
        if ! self.skipper.valid?
          review_status['crew'] = 'Skepparens kontaktuppgifter behöver kompletteras.'
        end
      end
    end

    #boat
    if self.boat.blank?
      review_status['boat'] = 'Vilken båt ska du segla med?'
    else
      if self.handicap_type.blank?
        review_status['boat'] = 'Vilken sorts handikapp ska du använda?'
      else
        if self.handicap.blank? && (['SrsKeelboat', 'SrsMultihull', 'SrsDingy', 'SrsCertificate', 'SxkCertificate'].include? self.handicap_type)
          review_status['boat'] = 'Vilken sorts handikapp ska du använda?'
        end
      end

    end

    review_status
  end

  def offshore_name
    unless self.offshore.nil?
      if self.offshore
        'Hav'
      else
        'Kust'
      end
    else
      ''
    end
  end

  def skipper_id
    if self.skipper.present?
      self.skipper.id
    else
      nil
    end
  end

  def skipper_first_name
    if self.skipper.present?
      self.skipper.first_name
    else
      nil
    end
  end

  def skipper_last_name
    if self.skipper.present?
      self.skipper.last_name
    else
      nil
    end
  end

  def has_finished_according_to_logbook?
    out = false
    for log in self.logs
      if JSON.parse(log.data)['finish'].present?
        out = (JSON.parse(log.data)['finish'] == 'true')
      end
    end
  end

  def set_sailing_state!
    # states:
    # not_started
    # did_not_start
    # started
    # did_not_finish
    # finished
    has_started = self.logs.where(log_type: 'round', deleted: false).present?
    has_cancelled = self.logs.where(log_type: 'retire', deleted: false).present?
    has_finished = false
    is_signed = false
    for log in self.logs.where(deleted: false)
      jsondata = JSON.parse(log.data)
      if jsondata['finish'].present?
        if jsondata['finish'] == 'true'
          has_finished = true
        end
      end
      if log.log_type == 'sign'
        is_signed = true
      end
    end

    if has_cancelled && has_started
      self.did_not_finish!
    elsif has_cancelled
      self.did_not_start!
    elsif has_finished
      self.finished!
    elsif has_started
      self.started!
    else
      self.not_started!
    end
    if is_signed
      self.signed!
    end
  end

  def is_signed
    self.state == 'signed' || self.state == 'reviewed' ||
      self.state == 'archived' || self.state == 'closed'
  end

  def get_logbook(logs)
    team = self
    terrain = team.race.regatta.terrain
    prev = nil
    npoints = {}
    nlegs = {}
    entries = []
    cur_compensation_time = 0
    cur_compensation_dist_time = 0
    admin_time = 0
    admin_dist = 0
    compensation_time = 0
    compensation_dist_time = 0
    start_time = 0
    finish_time = 0
    signed = false
    state = nil
    sailed_dist = 0
    sailed_time = 0
    i = 0
    while i < logs.length do
      log = logs[i]
      unless log.deleted
        leg_dist = nil
        leg_time = nil
        leg_speed = nil
        leg_status = nil
        interrupt_status = nil
        prev_point = nil
        unless log.data.blank?
          log_data = JSON.parse(log.data)
        else
          log_data = Hash.new
        end
        if log.point
          # start or round
          unless npoints[log.point]
            npoints[log.point] = 0
          end
          if prev.nil?
            start_time = log.time.to_i
          else
            prev_point = prev.point
            leg_time = (log.time.to_i - prev.time.to_i) / 60
            unless log_data['finish'].blank?
              finish_time = log.time.to_i
            else
              # count this point (it is not start since it has prev_point)
              # NOTE: we count this point even if the leg is invalid.
              # unclear if this is correct or not.
              npoints[log.point] = npoints[log.point] + 1
            end
            leg = find_leg(prev.point, log.point, terrain)
            if leg
              leg_speed = (60 * leg.distance) / leg_time
            end
            if leg && npoints[log.point] < 3
              # count this leg
              leg_name = get_leg_name(prev.point, log.point)
              if nlegs[leg_name]
                nlegs[leg_name] = nlegs[leg_name] + 1
              else
                nlegs[leg_name] = 1
              end
              if nlegs[leg_name] < 3
                if leg.distance == 0 && leg.addtime
                  # zero-distance leg with time compensation;
                  # add the time to offset, and ignore compensation in
                  # ongoing interrupts
                  compensation_time += leg_time
                else
                  leg_dist = leg.distance
                  sailed_dist += leg_dist
                  compensation_time += cur_compensation_time
                  compensation_dist_time += cur_compensation_dist_time
                end
              else
                leg_status = :too_many_legs
              end
            elsif leg.nil?
              leg_status = :no_leg
            else
              leg_status = :too_many_rounds
            end
            sailed_time += leg_time
            # reset compensation counters
            cur_compensation_time = 0
            cur_compensation_dist_time = 0
          end
          prev = log
        elsif log_data['interrupt'] && log_data['interrupt']['type'] != 'done'
          # Find the corresponding log entry for interrupt done
          j = i+1
          found = false
          while !found && j < logs.length do
            f = logs[j]
            unless f.deleted
              if f.log_type == 'interrupt'
                unless f.data.blank?
                  f_log_data = JSON.parse(f.data)
                else
                  f_log_data = Hash.new
                end
                if f_log_data['interrupt'] &&
                   f_log_data['interrupt']['type'] == 'done'
                  interrupt_time = (f.time.to_i - log.time.to_i) / 60
                  if log_data['interrupt']['type'] == 'rescue-time'
                    cur_compensation_time += interrupt_time
                  elsif log_data['interrupt']['type'] == 'rescue-dist'
                    cur_compensation_dist_time += interrupt_time
                  end
                  # no compensation for other interrupts
                  found = true
                end
              elsif f.log_type == 'round'
                # A rounding log entry before starting to sail again - error
                interrupt_status = :no_done
                found = true
              elsif f.log_type == 'interrupt'
                # A new interrupt "replaced" this one
                found = true
              end
            end
            j += 1
          end
        elsif log.log_type == 'sign'
          signed = true
        elsif log.log_type == 'retire'
          if start_time == 0
            state = :dns
          else
            state = :dnf
          end
        elsif log.log_type == 'adminDSQ'
          state = :dsq
        elsif log.log_type == 'adminDist'
          admin_dist += log_data['admin_dist']
        elsif log.log_type == 'adminTime'
          admin_time += log_data['admin_time']
        end
        entries.append({:log => log,
                        :log_data => log_data,
                        :distance => leg_dist,
                        :speed => leg_speed,
                        :leg_status => leg_status,
                        :prev_point => prev_point,
                        :interrupt_status => interrupt_status})
      end
      i += 1
    end

    early_start_time = 0
    # all start_* vars are in seconds (since Unix epoch)
    if start_time > 0
      start_from = team.race.start_from.to_i
      start_to = team.race.start_to.to_i
      if start_time > start_to
        # late start, use "start-to" as starttime (RR 6.3)
        start_time = start_to
      elsif start_time < start_from
        # too early start; add penalty, use "start-from" as starttime
        early_start_time = (start_from - start_time) / 60
        start_time = start_from
      end
    end

    late_finish_time = 0
    if finish_time > 0
      extra_time = compensation_time + admin_time
      race_length = (team.race.period * 60 + extra_time) * 60
      # FIXME: verify that it is correct to not add extra time here
      race_min_length = (team.race.minimal.to_i * 60) * 60
      real_finish_time = start_time + race_length
      min_finish_time = start_time + race_min_length
      if finish_time > real_finish_time
        # too late finish
        late_finish_time = (finish_time - real_finish_time) / 60
      elsif finish_time < min_finish_time
        # too short race, does not count
        state = :early_finish
      end
    end

    # we can't calculate early_start_dist properly until the race has finished
    early_start_dist = 0
    if finish_time > 0
      early_start_dist = (2 * sailed_dist * early_start_time) /
                         (team.race.period * 60)
    end

    late_finish_dist = 0
    if late_finish_time > 0
      late_finish_dist = (2 * sailed_dist * late_finish_time) /
                         (team.race.period * 60)
    end

    average_speed = 0
    # use sailed time - time for interrupts that gets compensated
    time = sailed_time - compensation_time
    if time > 0
      average_speed = sailed_dist * 60 / time
    end

    # we can't calculate compensation_dist properly until the race has finished
    compensation_dist = 0
    if finish_time > 0
      compensation_dist = (average_speed * compensation_dist_time) / 60;
    end

    approved_dist = 0
    plaque_dist = 0
    if signed and state.nil?
      approved_dist = sailed_dist + compensation_dist -
                      (early_start_dist + late_finish_dist)
      plaque_dist = (approved_dist / team.sxk) - admin_dist
    end

    { :state => state,
      :signed => signed,
      :entries => entries,
      :sailed_dist => sailed_dist,
      :early_start_dist => early_start_dist,
      :early_start_time => early_start_time,
      :late_finish_dist => late_finish_dist,
      :late_finish_time => late_finish_time,
      :compensation_dist => compensation_dist,
      :admin_dist => admin_dist,
      :approved_dist => approved_dist,
      :plaque_dist => plaque_dist
    }
  end

  def get_known_handicaps
    # FIXME: create index on team.boat_id
    # normally, this array contains a single value, or is empty.
    # get all teams where this boat has participated
    known_handicaps = Array.new
    for t in Team.where("boat_id = ?", self.boat_id).order("created_at DESC")
      h = t.handicap
      if t.id != self.id and not h.nil?
        if h.registry_id.nil?
          # try to find active with same name
          known_handicaps = Handicap.
                              where("type = ?", h.type).
                              where("name = ?", h.name).
                              active
        else
          # try to find active with same registry id
          known_handicaps = Handicap.
                              where("type = ?", h.type).
                              where("registry_id = ?", h.registry_id).
                              active
        end
        if !known_handicaps.empty?
          # we found a current handicap (or more) for the most recent team,
          # suggest that to the user
          break
        end
      end
    end
    known_handicaps
  end

private

  def set_default_state
    self.state = :draft
    #self.sailing_state = 'not_started'
  end

  def get_leg_name(a, b)
    if a < b
      "#{a}-#{b}"
    else
      "#{b}-#{a}"
    end
  end

  def find_leg(previous_point_number, point_number, terrain)
    previous_point = terrain.points.find_by number: previous_point_number
    point = terrain.points.find_by number: point_number
    terrain.legs.find_by point: previous_point, to_point: point
  end

end
