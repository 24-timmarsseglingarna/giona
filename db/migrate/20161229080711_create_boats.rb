class CreateBoats < ActiveRecord::Migration[5.0]
  def change
    create_table :boats do |t|
      t.string :name
      t.string :boat_type_name
      t.integer :sail_number
      t.string :vhf_call_sign
      t.string :ais_mmsi
      t.integer :external_id
      t.string :external_system

      t.timestamps
    end
  end
end
