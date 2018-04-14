class Agreement < ApplicationRecord
  has_many :consents
  has_many :agreements, through: :consents
end
