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
    where("logs.log_type = ?", t)
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

end
