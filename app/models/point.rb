class Point < ApplicationRecord
  has_and_belongs_to_many :terrains
  has_many :legs, dependent: :destroy
  has_many :reverse_legs, dependent: :destroy, :class_name => "Leg", foreign_key: "to_point_id"

  default_scope { order(number: :asc) }
  validates_presence_of :number, :name, :definition, :latitude, :longitude, :version
  validates_numericality_of :latitude, :longitude, :version
  validates_numericality_of :number, :greater_than => 0
end
