class MarathonController < ApplicationController
  include ApplicationHelper

  def index
    @year = params[:year].present? ? params[:year].to_i : nil
    @organizer_id = params[:organizer_id].present? ? params[:organizer_id].to_i : nil
    # Highlight mode: 'new_plaques' (plaques crossed in the selected year) or
    # 'near_plaque' (within NEAR_PLAQUE_DIST of the next plaque).
    @highlight = params[:highlight].presence
    # When 'selected', show only the highlighted rows (new plaque / next plaque).
    @show_selected = params[:show] == 'selected'
    @organizers = Organizer.marathon_eligible

    logs = MarathonLog.all
    logs = logs.where('date >= ?', Date.new(@year, 1, 1)) if @year
    logs = logs.where(organizer_id: @organizer_id) if @organizer_id

    # Person IDs matched by the active filters
    filtered_person_ids = logs.distinct.pluck(:marathon_person_id)

    marathon_people = MarathonPerson.where(id: filtered_person_ids)
                                    .includes(:people).index_by(&:id)

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
      if @highlight == 'new_plaques' && @year
        prev_total = all_logs.select { |l| l.date.year < @year || l.team_id.nil? }
                             .sum(&:plaque_dist)
        new_p      = MarathonThresholds.new_plaques(prev_total, total_plaque_dist)
      else
        new_p = []
      end

      # Within NEAR_PLAQUE_DIST nautical miles of the next plaque.
      if @highlight == 'near_plaque'
        dist_to_next = MarathonThresholds.dist_to_next_plaque(total_plaque_dist)
        near_plaque  = dist_to_next && dist_to_next <= NEAR_PLAQUE_DIST
        next_p       = near_plaque ? MarathonThresholds.next_plaque(total_plaque_dist) : nil
      else
        near_plaque = false
        next_p      = nil
      end

      {
        marathon_person:   mp,
        total_sailed_dist: all_logs.sum(&:sailed_dist),
        total_plaque_dist: total_plaque_dist,
        latest_boat_name:  latest&.boat_name,
        latest_boat_type:  latest&.boat_type,
        latest_year:       latest&.date&.year,
        latest_organizer:  organizers_by_id[latest&.organizer_id],
        new_plaques:       new_p,
        near_plaque:       near_plaque,
        next_plaque:       next_p
      }
    end.compact

    @rows.sort_by! { |r| -r[:total_plaque_dist] }
    @rows.each_with_index { |r, i| r[:place] = i + 1 }

    # Email addresses of the sailors near a plaque (officer-only listing).
    if has_officer_rights? && @highlight == 'near_plaque'
      @near_emails = @rows.select { |r| r[:near_plaque] }
                          .flat_map { |r| r[:marathon_person].people.map(&:email) }
                          .reject(&:blank?).uniq
    end

    # Keep only highlighted rows, preserving each row's overall placement.
    if @show_selected && @highlight
      @rows = @rows.select { |r| r[:new_plaques].any? || r[:near_plaque] }
    end

    file_name = "Maratonlistan--#{Time.now.strftime('%Y%m%d')}".parameterize
    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=#{file_name}.xlsx"
      }
    end
  end
end
