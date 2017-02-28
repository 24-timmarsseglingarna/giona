module Api
  module V1
    class PeopleController < ApiController
      acts_as_token_authentication_handler_for User
      
      def index
        respond_with Person.all
      end

      def show
        respond_with Person.find(params[:id])
      end
    end
  end
end