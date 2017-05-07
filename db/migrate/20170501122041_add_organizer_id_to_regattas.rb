class AddOrganizerIdToRegattas < ActiveRecord::Migration[5.0]
  def change
    add_column :regattas, :organizer_id, :integer
  end
end
