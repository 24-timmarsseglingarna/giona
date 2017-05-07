module RacesHelper
  def race_brief race
    out = ''
    out += race.period.to_s + ' timmar. '
    out += race.description + '. ' unless race.description.blank? 
    out += ' Start: ' + I18n.l(race.start_from.in_time_zone, format: :long)
  	if race.start_from. != race.start_to
      out += ' – '
      if race.start_from.to_date == race.start_to.to_date 
  	    out += I18n.l(race.start_to.in_time_zone, format: :clock)
  	  else
  	  	out += I18n.l(race.start_to.in_time_zone, format: :short)
  	  end
    end
  	out
  end # def race_brief

  def race_start race
    # Exact start moment
    # Period, same day
    # Period, over days

    out = I18n.l(race.start_from.in_time_zone, format: :long)
    if race.start_from. != race.start_to
      out += ' – '
      if race.start_from.to_date == race.start_to.to_date 
        out += I18n.l(race.start_to.in_time_zone, format: :clock)
      else
        out += I18n.l(race.start_to.in_time_zone, format: :short)
      end
    end
    out
  end # def race_brief


end
