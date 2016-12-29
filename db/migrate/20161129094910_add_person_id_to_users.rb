class AddPersonIdToUsers < ActiveRecord::Migration[5.0]
  def change
  	add_column 	:users, :person_id, :integer
  	add_index 	:users, :person_id
  end
end
