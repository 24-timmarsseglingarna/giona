class ChangeNameOfNameToDescriptionOnRace < ActiveRecord::Migration[5.0]
  def change
    rename_column :races, :name, :description
  end
end
