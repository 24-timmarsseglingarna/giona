class ApiController < ActionController::Base

  before_action :insert_token_headers
  respond_to :json
  protect_from_forgery with: :null_session

  protected

  def insert_token_headers
    if current_user
      response.headers["X-User-Email"] = "#{current_user.email.to_s}"
      response.headers["X-User-Id"] = "#{current_user.id.to_s}"
      response.headers["X-User-Token"] = "#{current_user.authentication_token}"
    end
  end

  private

  def user_not_authorized
    flash[:alert] = "Du har inte behörighet till det här."
    redirect_to(request.referrer || root_path)
  end

end
