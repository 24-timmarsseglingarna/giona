class AddToPointIndexToLegs < ActiveRecord::Migration[5.0]
  def change
    add_index :legs, :to_point_id    
  end
end
