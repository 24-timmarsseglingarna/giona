class AddHandicapTypeToTeam < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :handicap_type, :string
  end
end
