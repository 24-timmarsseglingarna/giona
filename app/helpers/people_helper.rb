module PeopleHelper
  def user_role person
    user = User.find_by person_id: person.id
    if user
      user.role
    else
      "nej"
    end
  end
end
