module TeamsHelper
  def team_in_regatta team
  	out = team.name
  	unless team.race.nil?
  	  out += ': ' + team.race.period.to_s + ' timmar'
  	  unless team.race.regatta.nil?
  	  	out += ', ' + team.race.regatta.name
  	  end
  	 end
   end

   def i_may_see_links_to team
     if team.present?
       if !team.archived?
         if current_user
           if has_assistant_rights?
             true # is some kind of admin
           else
             if current_user.person.present?
               if team.people.present?
                 if team.people.include? current_user.person
                   true # is crew member
                 else
                   false
                 end
               else
                 false
               end
             else
               false
             end
           end
         else # current_user
           true # is not logged in (but shall see the link)
         end
       else # archived?
         false
       end
     else # team.present?
       false
     end
   end

   def panel_context status
     if status.blank?
       "panel-success"
     else
       "panel-danger"
     end
   end

   def distance_between( previous_point_number, point_number, terrain)
     previous_point = terrain.points.find_by number: previous_point_number
     point = terrain.points.find_by number: point_number
     leg = terrain.legs.find_by point: previous_point, to_point: point
     if leg
       leg.distance
     else
       0.0
     end
   end
end
