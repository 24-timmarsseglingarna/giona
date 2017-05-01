class AddExternalIdAndExternalSystemToRegattas < ActiveRecord::Migration[5.0]
  def change
    add_column :regattas, :external_id, :string
    add_column :regattas, :external_system, :string
  end
end
