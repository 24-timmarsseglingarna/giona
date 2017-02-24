class ApplicationController < ActionController::Base
  include Pundit
  #protect_from_forgery

  before_action :authenticate_user!
  before_action :insert_token_headers
  #protect_from_forgery with: :exception

  
  acts_as_token_authentication_handler_for User
  respond_to :html, :json
  protect_from_forgery with: :null_session

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

  def after_successful_token_authentication
    # Make the authentication token to be disposable - for example
    #renew_authentication_token!
  end


  def insert_token_headers
    if current_user
      response.headers["X-User-Email"] = "#{current_user.email}"
      response.headers["X-User-Token"] = "#{current_user.authentication_token}"
    end
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end


  def after_successful_token_authentication
    # Make the authentication token to be disposable - for example
    logger.info "**************TOKEN AUTH***************************"
    renew_authentication_token!
  end

end
