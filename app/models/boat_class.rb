class BoatClass < ApplicationRecord
  has_many :boats, dependent: :destroy
  scope :has_boat, ->(b_id) {joins(:boats).where("boats.id = ?", b_id)}
  #validates_presence_of :name
  validates :handicap, numericality: true
end