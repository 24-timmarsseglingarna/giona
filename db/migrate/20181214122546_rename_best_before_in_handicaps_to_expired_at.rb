class RenameBestBeforeInHandicapsToExpiredAt < ActiveRecord::Migration[5.0]
  def change
    rename_column :handicaps, :best_before, :expired_at
  end
end
