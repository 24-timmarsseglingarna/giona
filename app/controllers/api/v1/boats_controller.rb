module Api
  module V1
    class BoatsController < ApiController
      
      has_scope :has_team

      def index
        respond_with apply_scopes(Boat).all
      end

      def show
        respond_with Boat.find(params[:id])
      end
    end
  end
end