class MarathonController < ApplicationController
  def index
    @year        = params[:year].present? ? params[:year].to_i : nil
    @organizer_id = params[:organizer_id].present? ? params[:organizer_id].to_i : nil
    @organizers  = Organizer.marathon_eligible

    logs = MarathonLog.all
    logs = logs.where(year: @year)         if @year
    logs = logs.where(organizer_id: @organizer_id) if @organizer_id

    # Group logs by marathon_person_id in Ruby to avoid N+1
    grouped = logs.group_by(&:marathon_person_id)
    all_person_ids = grouped.keys

    marathon_people = MarathonPerson.where(id: all_person_ids).index_by(&:id)

    # For new_plaques we need totals up to (year - 1) for each person.
    # Load all logs for those persons once.
    all_logs_for_persons = MarathonLog.where(marathon_person_id: all_person_ids)
                                      .group_by(&:marathon_person_id)

    @rows = all_person_ids.map do |mp_id|
      mp = marathon_people[mp_id]
      next unless mp

      dist_this_year  = grouped[mp_id].sum(&:plaque_dist)
      all_logs        = all_logs_for_persons[mp_id] || []
      total_dist      = all_logs.sum(&:plaque_dist)
      dist_prev_years = total_dist - dist_this_year

      if @year
        prev_total = all_logs.select { |l| l.year < @year }.sum(&:plaque_dist)
        new_p      = MarathonThresholds.new_plaques(prev_total, total_dist)
      else
        new_p = []
      end

      {
        marathon_person:  mp,
        dist_this_year:   dist_this_year,
        dist_prev_years:  dist_prev_years,
        total_plaque_dist: total_dist,
        current_plaque:   MarathonThresholds.current_plaque(total_dist),
        new_plaques:      new_p
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
