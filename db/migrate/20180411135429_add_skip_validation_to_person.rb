class AddSkipValidationToPerson < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :skip_validation, :boolean, default: true
    Person.update_all skip_validation: true
  end
end
