class AddNumberIndexToPoints < ActiveRecord::Migration[5.0]
  def change
    add_index :points, :number
  end
end
