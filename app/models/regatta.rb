class Regatta < ApplicationRecord
  has_many :races
  validates_presence_of :organizer, :name
  validates_uniqueness_of :name
end
