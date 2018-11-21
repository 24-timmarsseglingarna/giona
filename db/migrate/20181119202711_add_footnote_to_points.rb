class AddFootnoteToPoints < ActiveRecord::Migration[5.0]
  def change
    add_column :points, :footnote, :string
  end
end
