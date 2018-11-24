class PasswordsController < Devise::PasswordsController
  def create
    # When called from a REST client (like the app), the client must
    # set the "json" parameter, so e.g.:
    #   {"json": "1", "user": {"email": "user@domain"}}
    if params[:json].nil?
      # use default handling for web
      super
    else
      self.resource = resource_class.send_reset_password_instructions(
        resource_params)

      if successfully_sent?(self.resource)
        render json: {status: 'ok'}
      else
        if resource_params['email'] &&
           User.find_by(email: resource_params['email']).nil?
          render json: {error: ['no-such-email']}, status: 404
        else
          # this *could* probably be mail sending problem?
          render json: {error: ['unknown']}, status: 500
        end
      end
    end
  end
end
