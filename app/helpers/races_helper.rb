module RacesHelper
  def race_brief race
  	# Exact start moment
  	# Period, same day
  	# Period, over days

  	out = race.period.to_s + ' timmar, ' + I18n.l(race.start_from, format: :long)
  	if race.start_from. != race.start_to
      out += ' – '
      if race.start_from.to_date == race.start_to.to_date 
  	    out += I18n.l(race.start_to, format: :clock)
  	  else
  	  	out += I18n.l(race.start_to, format: :short)
  	  end
    end
  	out
  end # def race_brief

end
