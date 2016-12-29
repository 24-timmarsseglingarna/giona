class CreateBoats < ActiveRecord::Migration[5.0]
  def change
    create_table :boats do |t|
      t.string :name
      t.integer :sail_number
      t.string :vhf_call_sign
      t.string :ais_mmsi
      t.integer :boat_class_id
      t.integer :external_id
      t.string :external_system

      t.timestamps
    end
  end
end
