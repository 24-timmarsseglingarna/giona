class Organizer < ApplicationRecord

  default_scope { order 'name' }
  scope :is_active, -> (boolean) { joins(:regattas).where("regattas.active = ?", boolean) }
  scope :has_regatta, ->(r_id) { joins(:regattas).where("regattas.id = ?", r_id) }

  has_many :regattas, dependent: :destroy
  has_many :races, :through => :regattas
  has_many :start_finishes, dependent: :destroy
  has_many :start_places, -> { where(start: true) }, class_name: 'StartFinish'
  has_many :finish_places, -> { where(start: false) }, class_name: 'StartFinish'

  validates_presence_of :name
  validates_uniqueness_of :name, :external_id
end
