class Log < ApplicationRecord
  belongs_to :team

  scope :from_team, ->(t_id) {
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
    # FIXME: also fill in user_id from authenticated user
    if self.gen != nil
      self.gen += 1
    else
      self.gen = 1
    end
  end

end
