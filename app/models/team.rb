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
  scope :is_active, ->(value = true) { where(active: value) }
  scope :did_not_start, ->(value = true) { where(did_not_start: value) }
  scope :did_not_finish, ->(value = true) { where(did_not_finish: value) }
  scope :has_paid_fee, ->(value = true) { where(paid_fee: value) }

  accepts_nested_attributes_for :boat

  after_initialize :set_defaults, unless: :persisted?

  def sxk
    self.handicap.sxk
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
    str = ''
    if self.start_point.blank?
      str += 'Var vill du starta? '
    end
    if self.offshore.nil?
      str += 'Seglar du havssträckor eller bara kuststräckor? '
    end
    review_status['race_details'] = str

    #crew
    if self.people.blank?
      review_status['crew'] = 'Lägg till minst en i besättning.'
    else
      if self.skipper.blank?
        review_status['crew'] = 'Vem ska vara skeppare?'
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
          review_status['boat'] = 'Vilket handikapp ska du använda?'
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

private

end
