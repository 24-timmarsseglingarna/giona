class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery
  #protect_from_forgery with: :exception

  before_filter :authenticate

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized


  def after_sign_in_path_for(resource)
	if current_user.person.nil? 
	  people = Person.where(["email = ?", current_user.email])
	  if people.count == 1 # Associate user with person.
	  	flash[:notice] = "Välkommen! Kolla att vi har rätt uppgifter om dig och spara."
	  	edit_person_path(people.first)
	  elsif people.count > 1 # We found email address multiple times. Mark user and persons to be reviewed.
	  	current_user.review! 
	  	for person in people
	  	  person.review!
	  	end
	  	flash[:notice] = "Välkommen! Nu behöver vi några uppgifter om dig."
	  	new_person_path(:add_me => 'true')
	  else # Create new person.
	  	flash[:notice] = "Välkommen! Nu behöver vi några uppgifter om dig."
	  	new_person_path(:add_me => 'true')
	  end
	end
  end

  protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "demo" && password == "demo"
    end
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

end
