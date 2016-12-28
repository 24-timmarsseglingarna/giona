class Team < ApplicationRecord
  belongs_to :race, dependent: :destroy
  has_many :crew_members
  has_many :people, :through => :crew_members
  has_many :non_skipper_crew_members, -> { where(skipper: false) }, class_name: 'CrewMember'
  has_many :seamen, :through => :non_skipper_crew_members, :source => :person
  has_one :skipper_crew_members, -> { where(skipper: true) }, class_name: 'CrewMember'
  has_one :skipper, :through => :skipper_crew_members, :source => :person
  

  after_initialize :set_defaults, unless: :persisted?
  # The set_defaults will only work if the object is new

  def set_defaults
    self.did_not_start  ||= false
    self.did_not_finish  ||= false
    self.paid_fee  ||= false
    self.name ||= "#{self.boat_name} / #{boat_class_name}"
  end

  def xskipper
    cm = self.crew_members.where(skipper: true)
    if cm.nil?
      nil
    else
      cm.first.person
    end
  end

end
