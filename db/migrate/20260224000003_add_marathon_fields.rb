class AddMarathonFields < ActiveRecord::Migration[6.1]
  def change
    add_column :people,     :marathon_person_id, :integer
    add_foreign_key :people, :marathon_people, column: :marathon_person_id, on_delete: :nullify

    add_column :organizers, :marathon_eligible, :boolean, default: false, null: false
    add_column :regattas,   :marathon_eligible, :boolean, default: false, null: false
  end
end
