class Log < ApplicationRecord
  belongs_to :team

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
    # FIXME: seems as the stored time as microsecond resolution, but
    # when it is sent, it is rounded to milliseconds; then when it is
    # passed back it is parsed as having 0 microseconds.  This means
    # the app always gets the last log entry every time.
    # For example, stored: X.123456, sent as X.123, parsed to X.123000.
    where("logs.updated_at > ?", DateTime.parse(d))
  }

  scope :has_type, ->(t) {
    where("logs.log_type = ?", t)
  }

  scope :not_client, ->(t) {
    where("logs.client != ?", t)
  }

  scope :not_team, ->(t) {
    where("logs.team_id != ?", t)
  }

  # FIXME: add user_name 'virtual' column, and include it
  # instead of the user_id in the json


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
    unless JSON.parse(self.data)['wind'].blank?
      JSON.parse(self.data)['wind']['dir'] + ' ' + JSON.parse(self.data)['wind']['speed']
    end
  end

  def position
    unless JSON.parse(self.data)['position'].blank?
      JSON.parse(self.data)['position']
    end
  end

  def teams
    unless JSON.parse(self.data)['boats'].blank?
      regatta = self.team.race.regatta
      Team.from_regatta(regatta.id).where(start_number: JSON.parse(self.data)['boats'])
    end
  end


  def sails
    out = ''
    unless JSON.parse(self.data)['sails'].blank?
      if JSON.parse(self.data)['sails']['reef']
        out += 'rev, '
      elsif JSON.parse(self.data)['sails']['main']
        out += 'stor, '
      end
      if JSON.parse(self.data)['sails']['jib']
        out += 'fock, '
      elsif JSON.parse(self.data)['sails']['genoa']
        out += 'genua, '
      end
      if JSON.parse(self.data)['sails']['code']
        out += 'code, '
      elsif JSON.parse(self.data)['sails']['gennaker']
        out += 'gennaker, '
      elsif JSON.parse(self.data)['sails']['spinnaker']
        out += 'spinnaker, '
      end
      unless JSON.parse(self.data)['sails']['other'].blank?
        out += JSON.parse(self.data)['sails']['other'] + ', '
      end
    end
    out && out.sub(/, $/, '')
  end

end
