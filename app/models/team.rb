class Team < ApplicationRecord
  belongs_to :race
  belongs_to :boat
  has_many :crew_members, dependent: :destroy
  has_many :people, :through => :crew_members
  has_many :non_skipper_crew_members, -> { where(skipper: false) }, class_name: 'CrewMember'
  has_many :seamen, :through => :non_skipper_crew_members, :source => :person
  has_one :skipper_crew_members, -> { where(skipper: true) }, class_name: 'CrewMember'
  has_one :skipper, :through => :skipper_crew_members, :source => :person

  scope :from_race, ->(r_id) {joins(:race).where("races.id = ?", r_id) }
  scope :from_boat, ->(b_id) {joins(:boat).where("boats.id = ?", b_id) }
  scope :has_person, ->(p_id) {joins(:people).where("people.id = ?", p_id) }
  scope :is_active, ->(value = true) { where(active: value) }
  scope :did_not_start, ->(value = true) { where(did_not_start: value) }
  scope :did_not_finish, ->(value = true) { where(did_not_finish: value) }
  scope :has_paid_fee, ->(value = true) { where(paid_fee: value) }
  
  after_initialize :set_defaults, unless: :persisted?
  # The set_defaults will only work if the object is new

  def set_defaults
    self.did_not_start  ||= false
    self.did_not_finish  ||= false
    self.paid_fee  ||= false
    self.name ||= "#{self.boat_name} / #{boat_class_name}"
  end


end
