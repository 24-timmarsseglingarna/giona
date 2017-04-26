class CreateBoatTypesBoats < ActiveRecord::Migration[5.0]
  def change
    create_table :boat_types_boats do |t|
      t.references :boat, foreign_key: true
      t.references :boat_type, foreign_key: true
    end
  end
end
