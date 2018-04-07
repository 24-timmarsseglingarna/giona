class Note < ApplicationRecord
  belongs_to :team
  belongs_to :user
  validates_presence_of :description, :team, :user

end
