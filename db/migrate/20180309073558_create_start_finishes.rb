class CreateStartFinishes < ActiveRecord::Migration[5.0]
  def change
    create_table :start_finishes do |t|
      t.integer :point_number
      t.integer :organizer_id
      t.boolean :start

      t.timestamps
    end
  end
end
