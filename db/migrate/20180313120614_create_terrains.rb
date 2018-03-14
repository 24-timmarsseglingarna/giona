class CreateTerrains < ActiveRecord::Migration[5.0]
  def change
    create_table :terrains do |t|
      t.boolean :published, default: false
      t.string :version_name

      t.timestamps
    end
  end
end
