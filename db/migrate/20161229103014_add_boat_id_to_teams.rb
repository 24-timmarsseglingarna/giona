class AddBoatIdToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :boat_id, :integer
  end
end
