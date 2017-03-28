class AddActiveToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :active, :boolean, default: false
  end
end
