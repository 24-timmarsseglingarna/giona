class AddReviewToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :review, :boolean, default: false
  end
end
