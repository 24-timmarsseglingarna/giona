class MarathonPerson < ApplicationRecord
  has_many :people, foreign_key: :marathon_person_id
  has_many :marathon_logs, foreign_key: :marathon_person_id

  validates :first_name, :last_name, presence: true

  def initials
    "#{first_name.first.upcase}#{last_name.first.upcase}"
  end

  def full_name
    "#{first_name} #{last_name}"
  end
  def total_plaque_dist(up_to_year: nil)
    logs = marathon_logs
    logs = logs.where('year <= ?', up_to_year) if up_to_year
    logs.sum(:plaque_dist)
  end

  def plaque_dist_for_year(year)
    marathon_logs.where(year: year).sum(:plaque_dist)
  end
end
