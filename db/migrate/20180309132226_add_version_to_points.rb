class AddVersionToPoints < ActiveRecord::Migration[5.0]
  def change
    add_column :points, :version, :integer
  end
end
