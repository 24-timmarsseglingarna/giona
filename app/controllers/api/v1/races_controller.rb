module Api
  module V1
    class RacesController < ApiController

      has_scope :from_regatta, :has_team

      def index
        respond_with apply_scopes(Race).all
      end

      def show
        respond_with Race.find(params[:id])
      end
    end
  end
end