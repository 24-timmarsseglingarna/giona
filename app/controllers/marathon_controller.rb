class MarathonController < ApplicationController
  def index
    @year = params[:year].present? ? params[:year].to_i : nil
    @organizer_id = params[:organizer_id].present? ? params[:organizer_id].to_i : nil
    @show_new_plaques = params[:new_plaques].present?
    @organizers = Organizer.marathon_eligible

    logs = MarathonLog.all
    logs = logs.where('date >= ?', Date.new(@year, 1, 1)) if @year
    logs = logs.where(organizer_id: @organizer_id) if @organizer_id

    # Person IDs matched by the active filters
    filtered_person_ids = logs.distinct.pluck(:marathon_person_id)

    marathon_people = MarathonPerson.where(id: filtered_person_ids).index_by(&:id)

    # Load ALL logs for those persons — needed to compute pre-period totals for new_plaques
    all_logs_for_persons = MarathonLog.where(marathon_person_id: filtered_person_ids)
                                      .group_by(&:marathon_person_id)

    organizers_by_id = Organizer.all.index_by(&:id)

    @rows = filtered_person_ids.map do |mp_id|
      mp = marathon_people[mp_id]
      next unless mp

      all_logs   = all_logs_for_persons[mp_id] || []
      # Restrict totals and latest to the selected year range
      latest            = all_logs.max_by(&:date)
      total_plaque_dist = all_logs.sum(&:plaque_dist)

      # New plaques are those crossed during the selected year range. The
      # baseline is everything already accounted for before that range:
      # logs from earlier years, plus historical imports (no team_id) whose
      # plaques were awarded historically — regardless of the import's date.
      if @show_new_plaques && @year
        prev_total = all_logs.select { |l| l.date.year < @year || l.team_id.nil? }
                             .sum(&:plaque_dist)
        new_p      = MarathonThresholds.new_plaques(prev_total, total_plaque_dist)
      else
        new_p = []
      end

      {
        marathon_person:   mp,
        total_sailed_dist: all_logs.sum(&:sailed_dist),
        total_plaque_dist: total_plaque_dist,
        latest_boat_name:  latest&.boat_name,
        latest_boat_type:  latest&.boat_type,
        latest_year:       latest&.date&.year,
        latest_organizer:  organizers_by_id[latest&.organizer_id],
        new_plaques:       new_p
      }
    end.compact

    @rows.sort_by! { |r| -r[:total_plaque_dist] }

    file_name = "Maratonlistan--#{Time.now.strftime('%Y%m%d')}".parameterize
    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=#{file_name}.xlsx"
      }
    end
  end
end
