class Leg < ApplicationRecord
  has_and_belongs_to_many :terrains
  belongs_to :point
  belongs_to :to_point, :class_name => "Point"
  validates_presence_of :point_id, :to_point_id, :distance
  validates_numericality_of :distance, greater_than_or_equal_to: 0
end
