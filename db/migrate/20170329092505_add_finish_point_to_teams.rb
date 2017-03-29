class AddFinishPointToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :finish_point, :integer
  end
end
