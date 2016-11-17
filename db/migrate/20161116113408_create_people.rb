class CreatePeople < ActiveRecord::Migration[5.0]
  def change
    create_table :people do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :co
      t.string :street
      t.string :zip
      t.string :city
      t.date :birthday
      t.string :phone
      t.string :external_system
      t.string :external_id

      t.timestamps
    end
  end
end
