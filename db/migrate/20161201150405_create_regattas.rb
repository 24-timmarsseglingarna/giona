class CreateRegattas < ActiveRecord::Migration[5.0]
  def change
    create_table :regattas do |t|
      t.string :name
      t.string :organizer
      t.string :email_from
      t.string :name_from
      t.string :email_to
      t.text :confirmation

      t.timestamps
    end
  end
end
