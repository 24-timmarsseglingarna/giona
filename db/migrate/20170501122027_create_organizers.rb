class CreateOrganizers < ActiveRecord::Migration[5.0]
  def change
    create_table :organizers do |t|
      t.string :name
      t.string :email_from
      t.string :name_from
      t.string :email_to
      t.text :confirmation
      t.string :external_id
      t.string :external_system

      t.timestamps
    end
  end
end
