class AddOffshoreToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :offshore, :boolean, default: false
  end
end
