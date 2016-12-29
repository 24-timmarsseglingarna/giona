class CreateRaces < ActiveRecord::Migration[5.0]
  def change
    create_table :races do |t|
      t.datetime :start_from
      t.datetime :start_to
      t.integer :period
      t.boolean :common_finish
      t.boolean :mandatory_common_finish
      t.string :external_system
      t.string :external_id
      t.integer :regatta_id

      t.timestamps
    end
  end
end
