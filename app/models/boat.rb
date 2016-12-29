class Boat < ApplicationRecord
  belongs_to :boat_class
  #validates_presence_of :name
  validates :sail_number, numericality: { only_integer: true }
end
