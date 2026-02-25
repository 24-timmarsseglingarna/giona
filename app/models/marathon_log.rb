class MarathonLog < ApplicationRecord
  belongs_to :marathon_person
  belongs_to :team, optional: true
  belongs_to :organizer, optional: true

  validates :date, presence: true
  validates :sailed_dist, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :plaque_dist, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
