class Race < ApplicationRecord
  belongs_to :regatta
  has_many :teams, dependent: :destroy
  has_many :people, through: :teams
  #default_scope { order(period: :asc, start_from: :asc) }
  serialize :starts, Array

  scope :from_regatta, ->(r_id) { joins(:regatta).where("regattas.id = ?", r_id) }
  scope :regatta_is_active, -> { joins(:regatta).where("regattas.active = ?", true) }
  scope :is_active, -> (boolean) { joins(:regatta).where("regattas.active = ?", boolean) }
  scope :has_team, ->(t_id) { joins(:teams).where("teams.id = ?", t_id) }
  scope :is_long, -> { where("period > ?", 24) }
  scope :has_period, ->(period) {where("period = ?", period)}

  validates :start_from, presence: true
  validate :check_start_period
  validates_presence_of :regatta
  validates_numericality_of :common_finish, :greater_than => 0, :allow_nil => true

  delegate :name, to: :regatta, prefix: true

  before_save :default_values

  def self.periods
    ['12', '24', '48', '72', '96', '120']
  end

    def self.minimums
    {'12' => '10',
     '24' => '21',
     '48' => '44',
     '72' => '67',
     '96' => '90',
     '120' => '113'
    }
  end

  def minimal
    Race.minimums[self.period.to_s]
  end

  def organizer_name
    self.regatta.organizer.name
  end

  def organizer_id
    self.regatta.organizer.id
  end

  def self.from_organizer o_id
    Organizer.find(o_id).races
  end

  def name
    str = self.period.to_s + ' tim, '
    unless self.description.blank?
      str += self.description + ', '
    end
    if self.common_finish
      str += ' gemensamt mål'
    else
      str += ' mål vid start'
    end
    str
  end

  def to_s
    self.name
  end

  def finish_places
    finish_hash  = {"Vid startplatsen" => nil}
    for point in regatta.terrain.points do
      finish_hash["#{point.number} #{point.name}"] = point.number
    end
    finish_hash
  end

  def start_places
    start_hash = Hash.new
    for start in self.regatta.organizer.default_starts do
      point = self.regatta.terrain.points.find_by number: start.number
      unless point.blank?
        start_hash["#{start.number} #{point.name}"] = start.number
      end
    end
    start_hash
  end

  private

  def check_start_period
    if self.start_from.present?
      if self.start_to.present?
        if self.start_from > self.start_to
          errors.add(:start_to, "slutet på startperioden kan inte vara före början")
        end
      end
    end
  end

  def default_values
    if self.start_from.present?
      if self.start_to.blank?
        self.start_to = self.start_from
      end
    end
  end


end
