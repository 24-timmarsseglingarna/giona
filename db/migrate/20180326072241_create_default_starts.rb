class CreateDefaultStarts < ActiveRecord::Migration[5.0]
  def change
    create_table :default_starts do |t|
      t.integer :organizer_id
      t.integer :number

      t.timestamps
    end
  end
end
