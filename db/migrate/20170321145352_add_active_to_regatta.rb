class AddActiveToRegatta < ActiveRecord::Migration[5.0]
  def change
    add_column :regattas, :active, :boolean, default: false
  end
end
