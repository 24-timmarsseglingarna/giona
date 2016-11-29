class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery
  #protect_from_forgery with: :exception

  before_filter :authenticate

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

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
