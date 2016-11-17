class AddDeletedAtTimeToPeople < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :deleted_at, :time
  end
end
