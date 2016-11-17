class AddCountryToPeople < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :country, :string
  end
end
