module PeopleHelper
  def user_role person
    user = User.find_by person_id: person.id
    if user
      user.role
    else
      "nej"
    end
  end

  def authorized?
  	if current_user.person
      if current_user.person.id == @person.id 
      	true
      else
      	false
      end
    else
      false
    end
  end

end
