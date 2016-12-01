json.extract! regatta, :id, :name, :organizer, :email_from, :name_from, :email_to, :confirmation, :created_at, :updated_at
json.url regatta_url(regatta, format: :json)