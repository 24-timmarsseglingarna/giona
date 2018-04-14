class AddStateToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :state, :integer
    for team in Team.all
      team.draft! if team.state.nil?
    end
  end
end
