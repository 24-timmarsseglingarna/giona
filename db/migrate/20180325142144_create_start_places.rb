class CreateStartPlaces < ActiveRecord::Migration[5.0]
  def change
    create_table :start_places do |t|
      t.integer :organizer_id
      t.integer :number

      t.timestamps
    end
  end
end
