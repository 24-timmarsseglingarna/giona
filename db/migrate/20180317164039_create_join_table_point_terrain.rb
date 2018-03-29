class CreateJoinTablePointTerrain < ActiveRecord::Migration[5.0]
  def change
    create_join_table :points, :terrains do |t|
      t.index [:point_id, :terrain_id]
      t.index [:terrain_id, :point_id]
    end
  end
end
