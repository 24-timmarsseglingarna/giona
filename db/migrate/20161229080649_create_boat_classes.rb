class CreateBoatClasses < ActiveRecord::Migration[5.0]
  def change
    create_table :boat_classes do |t|
      t.string :name
      t.float :handicap
      t.integer :external_id
      t.string :external_system

      t.timestamps
    end
  end
end
