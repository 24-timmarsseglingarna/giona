class Organizer < ApplicationRecord

  default_scope { order 'name' }
  scope :is_active, -> (boolean) { joins(:regattas).where("regattas.active = ?", boolean) } 
  scope :has_regatta, ->(r_id) { joins(:regattas).where("regattas.id = ?", r_id) } 

  has_many :regattas, dependent: :destroy
  has_many :races, :through => :regattas
  
  validates_presence_of :name
  validates_uniqueness_of :name
end
