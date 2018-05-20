class AddSailingStateToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :sailing_state, :integer, default: 0
  end
end
