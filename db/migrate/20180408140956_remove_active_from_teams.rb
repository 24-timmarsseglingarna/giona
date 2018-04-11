class RemoveActiveFromTeams < ActiveRecord::Migration[5.0]
  def change
    remove_column :teams, :active, :boolean
  end
end
