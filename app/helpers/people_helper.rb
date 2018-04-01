module PeopleHelper

  def my_boats person
    boats = person.teams.pluck('boat_name').uniq
    boats.delete nil
    boats.to_sentence
  end

  def my_starts person
    start_numbers = person.teams.pluck('start_number').uniq
    start_numbers.delete nil
    start_numbers.to_sentence
  end

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
