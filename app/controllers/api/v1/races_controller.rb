module Api
  module V1
    class RacesController < ApiController

      has_scope :from_organizer, :from_regatta, :has_team, :has_period
      has_scope :is_active, :type => :boolean, allow_blank: true

      def index
        @races = apply_scopes(Race).all
        render 'races/index'
      end

      def show
        @race = Race.find(params[:id])
        render 'races/show'
        #respond_with Race.find(params[:id])
      end
    end
  end
end