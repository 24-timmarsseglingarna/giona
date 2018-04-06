class ChangeDefaultOffshoreOnTeams < ActiveRecord::Migration[5.0]
  def change
    change_column :teams, :offshore, :boolean, default: nil
  end
end
