class Regatta < ApplicationRecord
  has_many :races, dependent: :destroy
  has_many :teams, :through => :races
  has_many :people, :through => :teams
  belongs_to :organizer
  belongs_to :terrain

  scope :is_active, ->(value = true) { where(active: value) }
  scope :has_race, ->(r_id) { joins(:races).where("races.id = ?", r_id) }
  scope :from_organizer, ->(o_id) { joins(:organizer).where("organizers.id = ?", o_id)}
  validates_presence_of :organizer, :name, :terrain, :email_to, :email_from, :name_from
  validates_uniqueness_of :name
  validates :web_page, url: { allow_blank: true }


  def next_start_number
    start_number = self.teams.where("start_number is not null").pluck(:start_number).sort.last
    unless start_number.nil?
      start_number = start_number + 1
    else
      start_number = 1
    end
    start_number
  end

  def get_races_result
    rs = []
    for race in self.races.order(:start_from)
      logbooks = []
      race.teams.is_visible().each do |team|
        logbook = team.get_logbook(team.logs.order(:time, :id))
        logbook[:team] = team
        notes = []
        if logbook[:compensation_dist] != 0
          notes.push("Tillägg undsättning: #{logbook[:compensation_dist].round(1)} M")
        end
        route = ""
        route_notes = []
        seen = {}
        for e in logbook[:entries]
          if e[:log].log_type == 'adminDSQ'
            notes.push("Ogiltig segling. #{e[:log_data]['comment']}")
          elsif e[:log].log_type == 'adminNote'
            notes.push("#{e[:log_data]['comment']}")
          elsif e[:log].log_type == 'adminDist'
            notes.push("Distansavdrag: #{e[:log_data]['admin_dist'].round(1)} M. #{e[:log_data]['comment']}")
          end
          if e[:prev_point]
            route << "&nbsp;&nbsp;-&nbsp; "
          end
          if e[:log].point
            route << e[:log].point.to_s
            if e[:distance]
              route << "&nbsp;(#{e[:distance]})"
            elsif e[:prev_point]
              # this is an invalid leg
              leg_name = get_leg_name(e[:prev_point], e[:log].point)
              if e[:leg_status] == :too_many_rounds && !seen[e[:log].point]
                route_notes.push("Punkt #{e[:log].point} har rundats mer än 2 gånger och räknas inte. Se §7.3, §13.1.3 i RR-2018.")
                seen[e[:log].point] = true
              elsif e[:leg_status] == :too_many_legs && !seen[leg_name]
                route_notes.push("Sträckan #{e[:prev_point]} - #{e[:log].point} har seglats mer än 2 gånger och räknas inte. Se §7.5, §13.1.2 i RR-2018.")
                seen[leg_name] = true
              elsif e[:leg_status] == :no_leg && !seen[leg_name]
                route_notes.push("Mellan #{e[:prev_point]} och #{e[:log].point} finns ingen giltig sträcka.")
                seen[leg_name] = true
              end
              route << "&nbsp;(0)"
            end
          end
        end
        logbook[:notes] = notes
        logbook[:route] = route
        logbook[:route_notes] = route_notes
        # if the regatta is still active (we have a preliminary result), push
        # all logbooks, even incomplete ones
        if (logbook[:plaque_dist] != 0) || !logbook[:state].nil? || self.active
          logbooks.push(logbook)
        end
      end
      logbooks = logbooks.sort{ |a,b| -compare_logbook(a,b) }
      i = 1
      for logbook in logbooks
        logbook[:place] = i
        i = i + 1
      end
      if !logbooks.empty?
        rs.push({ :race => race,
                  :logbooks => logbooks})
      end
    end
    rs
  end

  private

  def validate_email_from
    if self.email_from.present?
      if ! EmailAddress.valid? self.email_from, host_validation: :syntax
        errors.add(:email_from, "det är något fel med mejladressen")
      end
    end
  end

   def wstate(state)
     # early_finish < dnf < dns < dsq
     if state == :early_finish
       4
     elsif state == :dnf
       3
     elsif state == :dns
       2
     elsif state == :dsq
       1
     else
       0
     end
   end

   def compare_logbook(a, b)
     if a[:plaque_dist] > 0 && b[:plaque_dist] > 0
       a[:plaque_dist] <=> b[:plaque_dist]
     elsif a[:plaque_dist] > 0
       1
     elsif b[:plaque_dist] > 0
       -1
     else
       wstate(a[:state]) <=> wstate(b[:state])
     end
   end

  def get_leg_name(a, b)
    if a < b
      "#{a}-#{b}"
    else
      "#{b}-#{a}"
    end
  end

end
