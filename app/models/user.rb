class User < ApplicationRecord

  belongs_to :person

  enum role: [:user, :assistant, :organizer, :admin]

  after_initialize :set_default_role, :if => :new_record?

  # Include default devise modules. Others available are:
  #  :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, 
         :recoverable, :rememberable, :trackable, :validatable
         # :confirmable

  acts_as_paranoid( :column => 'deleted_at', :column_type => 'time')

  def set_default_role
    self.role = :user
  end

  def review!
  	self.update_attribute(:review, true)
  end


end
