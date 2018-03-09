class CreatePoints < ActiveRecord::Migration[5.0]
  def change
    create_table :points do |t|
      t.integer :number
      t.string :name
      t.string :definition
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
