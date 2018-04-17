class Regatta < ApplicationRecord
  has_many :races, dependent: :destroy
  has_many :teams, :through => :races
  has_many :people, :through => :teams
  belongs_to :organizer
  belongs_to :terrain

  scope :is_active, ->(value = true) { where(active: value) }
  scope :has_race, ->(r_id) { joins(:races).where("races.id = ?", r_id) }
  scope :from_organizer, ->(o_id) { joins(:organizer).where("organizers.id = ?", o_id)}
  validates_presence_of :organizer, :name, :terrain
  validates_uniqueness_of :name

  def next_start_number
    start_number = self.teams.where("start_number is not null").pluck(:start_number).sort.last
    unless start_number.nil?
      start_number = start_number + 1
    else
      start_number = 1
    end
    start_number
  end

private

end
