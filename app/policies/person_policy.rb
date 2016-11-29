class PersonPolicy < ApplicationPolicy
  attr_reader :user, :person

  def initialize(user, person)
    @user = user
    @person = person
  end

  def update?
    user.admin? 
  end

end