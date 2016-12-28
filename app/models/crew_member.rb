class CrewMember < ApplicationRecord
  belongs_to :team, dependent: :destroy
  belongs_to :person, dependent: :destroy
end