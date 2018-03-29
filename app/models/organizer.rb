class Organizer < ApplicationRecord

  default_scope { order 'name' }
  scope :is_active, -> (boolean) { joins(:regattas).where("regattas.active = ?", boolean) }
  scope :has_regatta, ->(r_id) { joins(:regattas).where("regattas.id = ?", r_id) }

  has_many :regattas, dependent: :destroy
  has_many :races, :through => :regattas
  has_many :default_starts, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name, :external_id

  def reset_default_start
     self.defualt_start.delete_all
  end

end
