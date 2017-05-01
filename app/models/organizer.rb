class Organizer < ApplicationRecord

  default_scope { order 'name' }

  has_many :regattas
  has_many :races, :through => :regattas
  validates_presence_of :name
  validates_uniqueness_of :name
end
