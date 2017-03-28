class Race < ApplicationRecord
  belongs_to :regatta
  has_many :teams, dependent: :destroy
  
  scope :from_regatta, ->(r_id) { joins(:regatta).where("regattas.id = ?", r_id) } 
  scope :has_team, ->(t_id) { joins(:teams).where("teams.id = ?", t_id) }


  validates :start_from, presence: true

  validate :check_start_period

  def check_start_period
    errors.add(:base, "end date should be greater than start") if self.start_from > self.start_to
  end

end