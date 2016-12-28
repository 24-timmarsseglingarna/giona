class Race < ApplicationRecord
  belongs_to :regatta, dependent: :destroy
  has_many :teams
  
  validates :start_from, presence: true

  validate :check_start_period

  def name
  	self.regatta.name + ', period: ' + self.period.to_s + ', start från: ' + I18n.l(self.start_from)
  end

  def check_start_period
    errors.add(:base, "end date should be greater than start") if self.start_from > self.start_to
  end

end
