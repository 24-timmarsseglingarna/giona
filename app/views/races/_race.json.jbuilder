json.extract! race, :id, :start_from, :start_to, :period, :minimal, :description, :common_finish, 
 :regatta_id, :regatta_name, :organizer_id, :organizer_name, :created_at, :updated_at
json.url race_url(race, format: :json)
