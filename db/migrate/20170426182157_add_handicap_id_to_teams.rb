class AddHandicapIdToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :handicap_id, :integer
  end
end
