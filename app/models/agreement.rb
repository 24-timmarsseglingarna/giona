class Agreement < ApplicationRecord
  has_many :consents
  has_many :agreements, through: :consents
  validates_presence_of :name, :description
  validates_uniqueness_of :name, :description
end
