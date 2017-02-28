class ApiController < ActionController::Base
  include Pundit

  #before_action :authenticate_user!
  before_action :insert_token_headers
  
  respond_to :json
  protect_from_forgery with: :null_session

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def insert_token_headers
    if current_user
      response.headers["X-User-Email"] = "#{current_user.email}"
      response.headers["X-User-Token"] = "#{current_user.authentication_token}"
    end
  end

  private

  def user_not_authorized
    flash[:alert] = "Du har inte behörighet till det här."
    redirect_to(request.referrer || root_path)
  end

end
