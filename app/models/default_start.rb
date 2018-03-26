class DefaultStart < ApplicationRecord
  belongs_to :organizer
  validates_presence_of :number
  validates :number, uniqueness: { scope: :organizer_id }
  default_scope { order(number: :asc) }
end
