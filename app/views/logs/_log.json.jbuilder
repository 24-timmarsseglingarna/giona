json.extract! log, :id, :team_id, :time, :user_id, :client, :log_type, :point, :data, :deleted, :gen, :created_at, :updated_at
json.url log_url(log, format: :json)
