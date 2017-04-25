class Race < ApplicationRecord
  belongs_to :regatta
  has_many :teams, dependent: :destroy
  #default_scope { order(regatta_id: :desc, period: :asc) }
  
  scope :from_regatta, ->(r_id) { joins(:regatta).where("regattas.id = ?", r_id) } 
  scope :regatta_is_active, -> { joins(:regatta).where("regattas.active = ?", true) } 
  scope :is_active, -> (boolean) { joins(:regatta).where("regattas.active = ?", boolean) } 
  scope :has_team, ->(t_id) { joins(:teams).where("teams.id = ?", t_id) }
  scope :is_long, -> { where("period > ?", 24) }
  scope :has_period, ->(period) {where("period = ?", period)}
  validates :start_from, presence: true

  validate :check_start_period

  def check_start_period
    errors.add(:base, "end date should be greater than start") if self.start_from > self.start_to
  end

end