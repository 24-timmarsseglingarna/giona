class RemoveSkipperIndexFromCrewMembers < ActiveRecord::Migration[5.0]
  def change
  	remove_index :crew_members, column: [:team_id, :skipper]
  end
end
