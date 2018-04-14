class Person < ApplicationRecord

  has_one :user
  has_many :crew_members, dependent: :destroy
  has_many :teams, through: :crew_members
  has_many :consents
  has_many :agreements, through: :consents
  has_many :friends, -> { distinct }, :through => :teams, :source => :people
  has_many :boats, -> { distinct }, :through => :teams


  default_scope { order 'last_name, first_name' }

  scope :has_team, ->(t_id) { joins(:teams).where("teams.id = ?", t_id) }
  scope :has_user, ->(u_id) { joins(:user).where("users.id = ?", u_id) }

  acts_as_paranoid( :column => 'deleted_at', :column_type => 'time')

  validates_presence_of :first_name, :last_name, :country

  validates_presence_of :birthday,
                        :phone,
                        :email,
                        :street,
                        :zip,
                        :city, unless: Proc.new { |a| a.skip_validation? }

  validates :phone, telephone_number: {country: proc{|record| record.country}}, unless: Proc.new { |a| a.skip_validation? }

  after_initialize :set_defaults, unless: :persisted?
  # The set_defaults will only work if the object is new


  def set_defaults
    self.country  ||= 'Sverige'
  end

  def review!
  	self.update_attribute(:review, true)
  end

  def name
    out = "#{self.first_name} #{self.last_name}"
    out += ", #{self.city}" unless self.city.blank?
    out
  end


end
