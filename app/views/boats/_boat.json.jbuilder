json.extract! boat, :id, :name, :sail_number, :vhf_call_sign, :ais_mmsi, :boat_type_name, :external_id, :external_system, :created_at, :updated_at
json.url boat_url(boat, format: :json)