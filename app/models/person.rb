class Person < ApplicationRecord

  has_one :user
  has_many :crew_members, dependent: :destroy
  has_many :teams, through: :crew_members

  scope :has_team, ->(t_id) { joins(:teams).where("teams.id = ?", t_id) }
  scope :has_user, ->(u_id) { joins(:user).where("users.id = ?", u_id) }

  acts_as_paranoid( :column => 'deleted_at', :column_type => 'time')

  validates_presence_of :first_name
  validates_presence_of :last_name
  #validates_length_of :street, in: 2..100, allow_nil: true
  #validates_length_of :zip, in: 7..32, allow_nil: true
  #validates_length_of :city, in: 2..100, allow_nil: true
  validates_presence_of :country
  #validates_length_of :fax, in: 7..32, allow_nil: true
  #validates_length_of :fax, in: 7..32, allow_nil: true
  #validates_length_of :fax, in: 7..32, allow_nil: true		
  #validates_length_of :fax, in: 7..32, allow_nil: true

  after_initialize :set_defaults, unless: :persisted?
  # The set_defaults will only work if the object is new

  def set_defaults
    self.country  ||= 'Sverige'
  end

  def review!
  	self.update_attribute(:review, true)
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end

end
