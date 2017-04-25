class CreateSrsClasses < ActiveRecord::Migration[5.0]
  def change
    create_table :srs_classes do |t|
      t.string :name
      t.string :pdf_link
      t.string :klassning
      t.string :skl
      t.float :b
      t.float :d
      t.float :depl
      t.float :srs
      t.float :srs_wo_fly
      t.integer :boat_class_id
      t.integer :version
      t.string :version_name
      t.string :import_description
      t.float :handicap

      t.timestamps
    end
  end
end
