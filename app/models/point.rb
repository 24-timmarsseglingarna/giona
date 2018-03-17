class Point < ApplicationRecord

  has_and_belongs_to_many :terrains
  default_scope { order(number: :asc) }
end
