class ChangeCommonFinishInRaces < ActiveRecord::Migration[5.0]
  def change
    remove_column :races, :common_finish, :boolean
    remove_column :races, :mandatory_common_finish, :boolean
    add_column :races, :common_finish, :integer
  end
end
