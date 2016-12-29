class Boat < ApplicationRecord
  belongs_to :boat_class
  has_many :teams, dependent: :destroy
  #validates_presence_of :name
  validates :sail_number, numericality: { only_integer: true, allow_nil: true }
end
