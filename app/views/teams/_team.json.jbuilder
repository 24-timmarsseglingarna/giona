json.extract! team, :id, :race_id, :regatta_id, :external_id, :external_system, :name, :boat_name, :boat_type_name, :boat_sail_number, :start_point, :start_number, :plaque_distance, :did_not_start, :did_not_finish, :paid_fee, :created_at, :updated_at, :sxk, :state
json.url team_url(team, format: :json)
