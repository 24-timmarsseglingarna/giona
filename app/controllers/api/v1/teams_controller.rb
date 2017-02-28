module Api
  module V1
    class TeamsController < ApiController
      
      def index
        respond_with Team.all
      end

      def show
      	# TODO include relations to skipper and crew members.
        respond_with Team.find(params[:id])
      end
    end
  end
end