class AddVacanciesToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :vacancies, :string
  end
end
