class AddWebPageToRegatta < ActiveRecord::Migration[5.0]
  def change
    add_column :regattas, :web_page, :string
  end
end
