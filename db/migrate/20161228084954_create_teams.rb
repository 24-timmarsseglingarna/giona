class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.integer :race_id
      t.integer :external_id
      t.string :external_system
      t.string :name
      t.string :boat_name
      t.string :boat_class_name
      t.string :boat_sail_number
      t.integer :start_point
      t.integer :start_number
      t.float :handicap
      t.float :plaque_distance
      t.boolean :did_not_start
      t.boolean :did_not_finish
      t.boolean :paid_fee

      t.timestamps
    end
  end
end
