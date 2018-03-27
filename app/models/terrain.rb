class Terrain < ApplicationRecord

  default_scope { order(id: :desc) }
  validates_presence_of :version_name
  has_many :regattas
  has_and_belongs_to_many :points
  has_and_belongs_to_many :legs

  def self.select_terrain
    terrain_array  = {}
    for terrain in Terrain.where("published = true")
      terrain_array[terrain.name] = terrain.id
    end
    terrain_array
  end

def name
  if self.published
    out = 'R'
  else
    out = 'PR'
  end
  out +=  "#{self.id}: #{self.version_name} (importerad #{I18n.l self.created_at, format: :day})"
end

end
