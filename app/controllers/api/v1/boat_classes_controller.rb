module Api
  module V1
    class BoatClassesController < ApiController

      has_scope :has_boat

      def index
        respond_with apply_scopes(BoatClass).all
      end

      def show
        respond_with BoatClass.find(params[:id])
      end
    end
  end
end