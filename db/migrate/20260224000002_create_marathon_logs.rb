class CreateMarathonLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :marathon_logs do |t|
      t.integer :marathon_person_id, null: false
      t.integer :team_id
      t.float   :sailed_dist, null: false
      t.float   :plaque_dist, null: false
      t.string  :boat_type
      t.string  :boat_name
      t.date "date", null: false
      t.integer :organizer_id

      t.timestamps
    end
    add_index :marathon_logs, [:marathon_person_id, :team_id], unique: true, where: 'team_id IS NOT NULL'
    add_foreign_key :marathon_logs, :marathon_people, column: :marathon_person_id
    add_foreign_key :marathon_logs, :teams, on_delete: :nullify
    add_foreign_key :marathon_logs, :organizers, on_delete: :nullify
  end
end
