class AddWebPageToOrganizer < ActiveRecord::Migration[5.0]
  def change
    add_column :organizers, :web_page, :string
  end
end
