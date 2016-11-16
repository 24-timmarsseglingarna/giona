class Person < ApplicationRecord
  validates_length_of :first_name, in: 2..50
  validates_length_of :last_name, in: 2..50
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
end
