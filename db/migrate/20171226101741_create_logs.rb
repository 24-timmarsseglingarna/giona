class CreateLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :logs do |t|
      t.integer :team_id, index: true
      t.datetime :time
      t.integer :user_id
      t.string :client
      t.string :log_type
      t.integer :point
      t.string :data
      t.boolean :deleted, default: false
      t.integer :gen

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false, index: true
    end
  end
end
