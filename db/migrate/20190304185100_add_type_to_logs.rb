class AddTypeToLogs < ActiveRecord::Migration[5.0]
  def change
    add_column :logs, :type, :string
    Log.update_all type: "TeamLog"
  end
end
