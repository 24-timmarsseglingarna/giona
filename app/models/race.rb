class Race < ApplicationRecord
  belongs_to :regatta, dependent: :destroy
  
  validates :start_from, presence: true

  validate :check_start_period

  def check_start_period
    errors.add(:base, "end date should be greater than start") if self.start_from > self.start_to
  end

end
