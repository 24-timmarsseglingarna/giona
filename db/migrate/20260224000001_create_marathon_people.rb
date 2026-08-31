class CreateMarathonPeople < ActiveRecord::Migration[6.1]
  def change
    create_table :marathon_people do |t|
      t.string  :first_name, null: false
      t.string  :last_name,  null: false
      t.date    :birthday
      t.integer :hourglass

      t.timestamps
    end
    add_index :marathon_people, [:birthday, :last_name, :first_name]
  end
end
