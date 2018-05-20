class CreateLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :logs do |t|
      t.integer :team_id
      t.datetime :time
      t.integer :user_id
      t.string :client
      t.string :log_type
      t.integer :point
      t.string :data
      t.boolean :deleted, default: false
      t.integer :gen

      t.timestamps
    end
    add_index :logs, :team_id
    add_index :logs, :updated_at

  end
end
