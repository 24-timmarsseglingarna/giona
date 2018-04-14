class CreateConsents < ActiveRecord::Migration[5.0]
  def change
    create_table :consents do |t|
      t.belongs_to :agreement, index: true
      t.belongs_to :person, index: true
      t.timestamps
    end
  end
end
