class CreateSrsClasses < ActiveRecord::Migration[5.0]
  def change
    create_table :srs_classes do |t|
      t.string :name
      t.string :pdf_link
      t.string :klassning
      t.float :skl
      t.float :b
      t.float :d
      t.float :depl
      t.float :srs
      t.float :srs_u_flygande_segel
      t.integer :boat_class_id
      t.integer :version
      t.boolean :active
      t.string :import_description

      t.timestamps
    end
  end
end
