module RegattasHelper
  def race_starts regatta
    if regatta.races.present?
      starts = regatta.races.pluck(:start_from).sort
      out = starts.first.to_date.to_s
      if starts.count > 1
        out += ' - ' + starts.last.to_date.to_s
      end
    end
  end
end
