module Api
  module V1
    class RacesController < ApiController
      
      def index
        respond_with Race.all
      end

      def show
        respond_with Race.find(params[:id])
      end
    end
  end
end