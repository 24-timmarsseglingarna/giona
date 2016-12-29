class BoatClass < ApplicationRecord
  has_many :boats, dependent: :destroy
  #validates_presence_of :name
  validates :handicap, numericality: true
end