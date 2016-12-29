class CrewMember < ApplicationRecord
  belongs_to :team
  belongs_to :person
end