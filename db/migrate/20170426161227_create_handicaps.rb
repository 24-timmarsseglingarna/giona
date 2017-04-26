class CreateHandicaps < ActiveRecord::Migration[5.0]
  def change
    create_table :handicaps do |t|
      t.string :name
      t.float :handicap
      t.datetime :best_before
      t.string :source
      t.float :srs
      t.string :registry_id
      t.integer :sail_number
      t.string :boat_name
      t.string :owner_name
      t.string :external_system
      t.integer :external_id
      t.string :type

      t.timestamps
    end
  end
end
