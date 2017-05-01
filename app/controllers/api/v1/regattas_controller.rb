module Api
  module V1
    class RegattasController < ApiController

      has_scope :is_active, :type => :boolean, allow_blank: true
      has_scope :has_race, :from_organizer

      def index
        respond_with apply_scopes(Regatta).all
      end

      def show
        respond_with Regatta.find(params[:id])
      end
    end
  end
end