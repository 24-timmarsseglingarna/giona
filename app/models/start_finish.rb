class StartFinish < ApplicationRecord
  belongs_to :organizer
  validates_presence_of :point_number
  validates :point_number, uniqueness: { scope: :start }

end
