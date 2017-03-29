class ApplicationController < ActionController::Base
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protect_from_forgery #with: :exception

  before_action :insert_token_headers
  before_action :store_current_location, :unless => :devise_controller?
  respond_to :html

  def after_sign_in_path_for(resource)
    insert_token_headers
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
    else
      stored_location_for(resource) || root_path
    end
  end

  protected

  private

  def user_not_authorized
    flash[:alert] = "Du har inte behörighet till det här."
    redirect_to(request.referrer || root_path)
  end

  def insert_token_headers
    if current_user
      response.headers["X-User-Email"] = "#{current_user.email}"
      response.headers["X-User-Id"] = "#{current_user.id.to_s}"
      response.headers["X-User-Token"] = "#{current_user.authentication_token}"
    end
  end

  def store_current_location
    store_location_for(:user, request.url)
  end

end