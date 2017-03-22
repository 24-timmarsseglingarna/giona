class Regatta < ApplicationRecord
  has_many :races, dependent: :destroy
  has_many :teams, :through => :races

  scope :is_active, ->(value = true) { where(active: value) }
  scope :has_race, ->(r_id) { joins(:races).where("races.id = ?", r_id) }

  validates_presence_of :organizer, :name
  validates_uniqueness_of :name

end