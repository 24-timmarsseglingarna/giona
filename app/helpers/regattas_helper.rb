module RegattasHelper
  def race_starts regatta
    if regatta.races.present?
      starts = regatta.races.pluck(:start_from).sort
      out = starts.first.to_date.to_s
      if starts.count > 1
        out += ' - ' + starts.last.to_date.to_s
      end
      out
    end
  end

  def fmt_res_plaque_dist(logbook)
    if logbook[:plaque_dist] > 0
      "#{logbook[:plaque_dist].round(1)} M"
    elsif logbook[:state] == :dnf
      "DNF"
    elsif logbook[:state] == :dns
      "DNS"
    elsif logbook[:state] == :dsq
      "DSQ"
    elsif logbook[:state] == :early_finish
      "För kort segling"
    else
      "Ofullständig"
    end
  end

  def tracker_link(regatta)
    Rails.configuration.web_logbook_url + "?regatta=#{regatta.id}"
  end

end
