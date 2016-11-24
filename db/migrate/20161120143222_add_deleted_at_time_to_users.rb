class AddDeletedAtTimeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :deleted_at, :time
  end
end
