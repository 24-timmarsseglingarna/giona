module Api
  module V1
    class TeamsController < ApiController

      has_scope :from_regatta, :from_race, :from_boat, :has_person
      has_scope :is_active, :type => :boolean, allow_blank: true

      def index
        @teams = apply_scopes(Team).all
        render 'teams/index'
      end

      def show
        @team = Team.find(params[:id])
        render 'teams/show'
#        respond_with Team.find(params[:id])
      end
    end
  end
end
