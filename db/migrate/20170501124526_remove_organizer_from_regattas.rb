class RemoveOrganizerFromRegattas < ActiveRecord::Migration[5.0]
  def change
    remove_column :regattas, :organizer, :string
  end
end
