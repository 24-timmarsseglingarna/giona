module Api
  module V1
    class BoatsController < ApiController
      
      def index
        respond_with Boat.all
      end

      def show
        respond_with Boat.find(params[:id])
      end
    end
  end
end