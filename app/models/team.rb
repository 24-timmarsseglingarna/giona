class Team < ApplicationRecord
  belongs_to :race
  belongs_to :boat
  has_many :crew_members, dependent: :destroy
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
  scope :did_not_start, ->(value = true) { where(did_not_start: value) }
  scope :did_not_finish, ->(value = true) { where(did_not_finish: value) }
  scope :has_paid_fee, ->(value = true) { where(paid_fee: value) }
  # Team.is_active implemented as a scope

  accepts_nested_attributes_for :boat

  after_initialize :set_defaults, unless: :persisted?

  enum state: [:draft, :submitted, :approved, :signed, :reviewed, :archived]
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

  def self.from_regatta r_id
    Regatta.find(r_id).teams
  end

  def set_defaults
    self.did_not_start  ||= false
    self.did_not_finish  ||= false
    self.paid_fee  ||= false
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
      else
        if self.handicap.blank?
          unless (self.handicap_type = 'SxkCertificate') || (self.handicap_type = 'SxkCertificate')
            review_status['boat'] = 'Vilket handikapp ska du använda?'
          end
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

private

  def set_default_state
    self.state = :draft
  end

end
