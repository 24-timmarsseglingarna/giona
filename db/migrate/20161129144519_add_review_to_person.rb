class AddReviewToPerson < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :review, :boolean, default: false
  end
end
