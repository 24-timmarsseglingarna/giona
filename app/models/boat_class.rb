class BoatClass < ApplicationRecord
  has_many :boats
  #validates_presence_of :name
  validates :handicap, numericality: true
end