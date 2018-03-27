class AddStartsToRaces < ActiveRecord::Migration[5.0]
  def change
    add_column :races, :starts, :text
  end
end
