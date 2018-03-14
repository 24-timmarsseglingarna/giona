class Terrain < ApplicationRecord
  validates_presence_of :version_name
  has_many :regattas


  def self.select_terrain
    terrain_array  = {}
    for terrain in Terrain.find(:all, :order => "name ASC")
      terrain_array[terrain.name] = terrain.id
    end
    municipality_array
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
