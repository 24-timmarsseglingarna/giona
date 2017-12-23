class ChangeNameOfHandicapToSxkOnHandicap < ActiveRecord::Migration[5.0]
  def change
    rename_column :handicaps, :handicap, :sxk
  end
end
