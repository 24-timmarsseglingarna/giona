class AddNameToRaces < ActiveRecord::Migration[5.0]
  def change
    add_column :races, :name, :string
  end
end
