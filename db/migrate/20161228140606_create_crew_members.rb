class CreateCrewMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :crew_members do |t|
      t.integer :person_id
      t.integer :team_id
      t.boolean :skipper, default: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index :crew_members , [:person_id , :team_id] , :unique => true
    add_index :crew_members, :person_id
    add_index :crew_members, :team_id
    add_index :crew_members, [:team_id, :skipper] , :unique => true
  end
end
