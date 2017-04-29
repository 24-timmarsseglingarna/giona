class RenameBoatClassNameToBoatTypeOnTeam < ActiveRecord::Migration[5.0]
  def change
  	rename_column :teams, :boat_class_name, :boat_type_name
  end
end
