class RemoveBoatClassIdFromBoats < ActiveRecord::Migration[5.0]
  def change
    remove_column :boats, :boat_class_id, :integer
  end
end
