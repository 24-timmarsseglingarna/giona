module Api
  module V1
    class OrganizersController < ApiController

      has_scope :is_active, :type => :boolean, allow_blank: true
      has_scope :has_regatta

      def index
        respond_with apply_scopes(Organizer).all
      end

      def show
        respond_with Organizer.find(params[:id])
      end
    end
  end
end