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
end