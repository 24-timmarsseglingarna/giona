class User < ApplicationRecord

  enum role: [:user, :assistant, :organizer, :admin]

  after_initialize :set_default_role, :if => :new_record?

  # Include default devise modules. Others available are:
  #  :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, 
         :recoverable, :rememberable, :trackable, :validatable
         # :confirmable


  def set_default_role
    self.role = :user
  end

end
