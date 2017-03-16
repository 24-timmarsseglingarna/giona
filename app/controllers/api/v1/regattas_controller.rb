module Api
  module V1
    class RegattasController < ApiController

      def index
        respond_with Regatta.all
      end

      def show
        respond_with Regatta.find(params[:id])
      end
    end
  end
end