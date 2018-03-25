class CreateLegs < ActiveRecord::Migration[5.0]
  def change
    create_table :legs do |t|
      t.integer :point_id
      t.integer :to_point_id
      t.float :distance
      t.boolean :offshore, default: false
      t.integer :version

      t.timestamps
    end
  end
end
