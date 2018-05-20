class RemoveDidNotStartAndDidNotFinishAndPaidFeeFromTeams < ActiveRecord::Migration[5.0]
  def change
    remove_column :teams, :did_not_start, :boolean
    remove_column :teams, :did_not_finish, :boolean
    remove_column :teams, :paid_fee, :boolean
  end
end
