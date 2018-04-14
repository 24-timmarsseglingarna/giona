class Consent < ApplicationRecord
  belongs_to :agreement
  belongs_to :person
end
