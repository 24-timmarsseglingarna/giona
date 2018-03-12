class Regatta < ApplicationRecord
  has_many :races, dependent: :destroy
  has_many :teams, :through => :races
  belongs_to :organizer

  scope :is_active, ->(value = true) { where(active: value) }
  scope :has_race, ->(r_id) { joins(:races).where("races.id = ?", r_id) }
  scope :from_organizer, ->(o_id) { joins(:organizer).where("organizers.id = ?", o_id)}
  validates_presence_of :organizer, :name
end
