class Regatta < ApplicationRecord
  has_many :races
  has_many :teams, :through => :races

  validates_presence_of :organizer, :name
  validates_uniqueness_of :name

end