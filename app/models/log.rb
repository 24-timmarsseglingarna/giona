class Log < ApplicationRecord
  belongs_to :team
  #validates_presence_of :team_id, :time, :log_type, :gen ## FIXME

  scope :from_team, ->(t_id) {
    where("logs.team_id = ?", t_id)
  }
  scope :has_team, ->(t_id) {
    where("logs.team_id = ?", t_id)
  }
  scope :from_regatta, ->(r_id) {
    joins(team: :race).where("races.regatta_id = ?", r_id)
  }
  scope :updated_after, ->(d) {
    where("logs.updated_at > ?", DateTime.parse(d).strftime('%Y-%m-%d %H:%M:%S.%N'))
  }

  scope :has_type, ->(t) {
    # use "," to OR types. "has_type=round,retire" for example
    where(log_type:  t.split(","))
  }

  scope :not_client, ->(t) {
    where("logs.client != ?", t)
  }

  scope :not_team, ->(t) {
    where("logs.team_id != ?", t)
  }

  before_save do
    if self.gen != nil
      self.gen += 1
    else
      self.gen = 1
    end
  end

  def user_name
    unless self.user_id.blank?
      user = User.find self.user_id
      unless user.person.first_name.blank? && user.person.last_name.blank?
        "#{user.person.first_name} #{user.person.last_name}"
      else
        user.email
      end
    end
  end

  def wind
    data = JSON.parse(self.data)
    unless data['wind'].blank?
      data['wind']['dir'] + ' ' + data['wind']['speed']
    end
  end

  def position
    data = JSON.parse(self.data)
    unless data['position'].blank?
      data['position']
    end
  end

  def teams
    data = JSON.parse(self.data)
    if !data['teams'].blank?
      regatta = self.team.race.regatta
      Team.where(id: data['teams'])
    elsif !data['boats'].blank?
      regatta = self.team.race.regatta
      Team.from_regatta(regatta.id).where(start_number: data['boats'])
    end
  end


  def sails
    out = ''
    data = JSON.parse(self.data)
    unless data['sails'].blank?
      if data['sails']['reef']
        out += 'rev, '
      elsif data['sails']['main']
        out += 'stor, '
      end
      if data['sails']['jib']
        out += 'fock, '
      elsif data['sails']['genoa']
        out += 'genua, '
      end
      if data['sails']['code']
        out += 'code, '
      elsif data['sails']['gennaker']
        out += 'gennaker, '
      elsif data['sails']['spinnaker']
        out += 'spinnaker, '
      end
      unless data['sails']['other'].blank?
        out += data['sails']['other'] + ', '
      end
    end
    out && out.sub(/, $/, '')
  end

  # Find teams that have two consecutive 'round' log entries between points A and B
  # The two 'round' entries must be consecutive when ordered by time, but there may be
  # other log_types between them. The order can be either A->B or B->A.
  def self.find_teams_with_dist(point_a, point_b)
    # Find all teams that have both points in their round logs
    teams_with_point_a = joins(:team)
      .where(log_type: 'round', deleted: false, point: point_a)
      .pluck(:team_id)
      .uniq

    teams_with_point_b = joins(:team)
      .where(log_type: 'round', deleted: false, point: point_b)
      .pluck(:team_id)
      .uniq

    # Teams that have both points
    candidate_teams = teams_with_point_a & teams_with_point_b

    result_teams = []

    candidate_teams.each do |team_id|
      # Get all round logs for this team, ordered by time
      round_logs = where(team_id: team_id, log_type: 'round', deleted: false)
                    .order(:time)
                    .select(:id, :time, :point)

      # Check for consecutive A-B or B-A patterns
      (0...round_logs.length - 1).each do |i|
        current_log = round_logs[i]
        next_log = round_logs[i + 1]

        # Check if we have A->B or B->A pattern
        if (current_log.point == point_a && next_log.point == point_b) ||
           (current_log.point == point_b && next_log.point == point_a)
          result_teams << team_id
          break # Found what we need for this team
        end
      end
    end

    Team.where(id: result_teams)
  end

end
