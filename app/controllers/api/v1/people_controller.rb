module Api
  module V1
    class PeopleController < ApiController

      acts_as_token_authentication_handler_for User

      before_action :insert_token_headers

      has_scope :has_team, :has_user

      def index
        render :json => apply_scopes(Person).all #TODO select which attributes to show
      end

      def show
        if current_user
          @person = Person.find(params[:id])
        else
          @person = Person.select("id, first_name, last_name").find(params[:id])
        end
        render :json => @person
      end
    end
  end
end