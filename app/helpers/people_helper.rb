module PeopleHelper

  def my_boats person
    boats = person.teams.pluck('boat_name').uniq
    boats.delete nil
    boats.to_sentence
  end

  def my_starts person
    start_points = person.teams.pluck('start_point').uniq
    start_points.delete nil
    start_points.to_sentence
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
      	if has_assistant_rights?
          true
        end
      end
    else
      false
    end
  end

end
