class Boat < ApplicationRecord
  has_many :teams, dependent: :destroy

  # scope :from_boat_class, ->(b_id) {joins(:boat_class).where("boat_classes.id = ?", b_id) } #TODO
  scope :has_team, ->(t_id) {joins(:teams).where("teams.id = ?", t_id)}
  #scope :from_race, ->(r_id) {joins(:race).where("races.id = ?", r_id) }
  #scope :from_boat, ->(b_id) {joins(:boat).where("boats.id = ?", b_id) }
  #scope :has_person, ->(p_id) {joins(:people).where("people.id = ?", p_id) }
  
  #validates_presence_of :name
  validates :sail_number, numericality: { only_integer: true, allow_nil: true }
end
