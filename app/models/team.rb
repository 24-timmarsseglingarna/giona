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

end
