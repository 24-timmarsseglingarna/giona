class CreateJoinTableLegTerrain < ActiveRecord::Migration[5.0]
  def change
    create_join_table :legs, :terrains do |t|
      t.index [:leg_id, :terrain_id]
      t.index [:terrain_id, :leg_id]
    end
  end
end
