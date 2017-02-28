module Api
  module V1
    class BoatClassesController < ApiController
      
      def index
        respond_with BoatClass.all
      end

      def show
        respond_with BoatClass.find(params[:id])
      end
    end
  end
end