module Api
  module V1
    class RacesController < ApiController

      has_scope :from_organizer, :from_regatta, :has_team, :has_period
      has_scope :is_active, :type => :boolean, allow_blank: true

      def index
        respond_with apply_scopes(Race).all
      end

      def show
        respond_with Race.find(params[:id])
      end
    end
  end
end