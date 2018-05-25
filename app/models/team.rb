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
  scope :is_visible, ->() {where("state > ?", 1)}
  #scope :did_not_start, ->(value = true) { where(did_not_start: value) }
  #scope :did_not_finish, ->(value = true) { where(did_not_finish: value) }
  #scope :has_paid_fee, ->(value = true) { where(paid_fee: value) }
  scope :from_regatta, ->(r_id) { joins(race: :regatta).where("regattas.id = ?", r_id) }

  # Team.is_active implemented as a scope

  accepts_nested_attributes_for :boat

  after_initialize :set_defaults, unless: :persisted?

  enum state: [:draft, :submitted, :approved, :signed, :reviewed, :archived]
  enum sailing_state: [:not_started, :did_not_start, :started, :did_not_finish, :finished]
  after_initialize :set_default_state, :if => :new_record?

  delegate :minimal, to: :race
  delegate :period, to: :race

  def self.is_active value = true
    if value
      where(:state => 1..4)
    else
      where.not(:state => 1..4)
    end
  end

  def self.is_archived value = true
    if value
      where(:state => 5)
    else
      where.not(:state => 5)
    end
  end


  def state_to_s
    str = Hash.new
    str['draft'] = 'utkast'
    str['submitted'] = 'inskickad'
    str['approved'] = 'godkänd'
    str[self.state]
  end

  def active
    self.visible?
  end

  def active?
    self.visible?
  end

  def visible?
    self.state > 0
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
    for log in self.logs.where(deleted: false)
      if JSON.parse(log.data)['finish'].present?
        if JSON.parse(log.data)['finish'] == 'true'
          has_finished = true
        end
      end
    end

    if has_cancelled
      self.did_not_finish!
    elsif has_finished
      self.finished!
    elsif has_started
      self.started!
    else
      self.not_started!
    end
  end

private

  def set_default_state
    self.state = :draft
    self.sailing_state = :not_started
  end

end
