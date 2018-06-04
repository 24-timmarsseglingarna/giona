# coding: utf-8
module Api
  module V1
    class LogsController < ApiController
      acts_as_token_authentication_handler_for User
      has_scope :has_team
      has_scope :from_team
      has_scope :from_regatta
      has_scope :updated_after
      has_scope :has_type
      has_scope :not_client
      has_scope :not_team

      def index
        @logs = apply_scopes(Log).all.select(:team_id, :time, :user_id, :client, :log_type, :deleted, :point, :gen)
        if params[:from_team]
          if user_signed_in?
            team = Team.find params[:from_team].to_i
            if team.people.include? current_user.person || has_organizer_rights?
              # team members gets all logentries, including "deleted"
              @logs = apply_scopes(Log).all
              render 'logs/index'
            else
              @logs = apply_scopes(Log).all.where(log_type: 'round', deleted: false)
              render 'logs/index_filtered'
            end
          else
            @logs = apply_scopes(Log).all.where(log_type: 'round', deleted: false)
          end
        else
          if user_signed_in? && has_organizer_rights?
            # organizers can view all non-deleted log entries
            @logs = apply_scopes(Log).all.where(deleted: false)
            render 'logs/index'
          else
            # others can (currently) view only type "round"
            @logs = apply_scopes(Log).all.where(log_type: 'round', deleted: false)
            render 'logs/index_filtered'
          end
        end
      end

      def show
        @log = Log.find params[:id]
        if user_signed_in?
          team = Team.find @log.team_id
          if team.people.include? current_user.person || has_organizer_rights?
            render 'logs/show'
          else
            @logs = Log.where(log_type: 'round', deleted: false, id: params[:id])
            respond_to do |format|
              if @logs.present?
                log = @logs.take
                format.json { render 'logs/show_filtered', status: :created, location: @log }
              else
                format.json { render json: 'Loggen finns inte eller kan inte visas.', status: :unprocessable_entity }
              end
            end #/respond_to
          end
        else
          @logs = Log.where(log_type: 'round', deleted: false, id: params[:id])
          respond_to do |format|
            if @logs.present?
              log = @logs.take
              format.json { render 'logs/show_filtered', status: :created, location: @log }
            else
              format.json { render json: 'Loggen finns inte eller kan inte visas.', status: :unprocessable_entity }
            end
          end #/respond_to
        end
      end

      def create
        authenticate_user!
        unless current_user
          format.json { render json: @log.errors, status: :unauthorized }
        else
          @log = Log.new(log_params)
          team = Team.find @log.team_id
          #unless team.people.include? current_user.person || has_organizer_rights?
          unless team.people.include? current_user.person
            render json: {
              error: "Du har inte behörighet, det har bara besättningsmedlemmar.",
              status: :forbidden
              }, status: :forbidden
          else
            @log.user_id = current_user.id if current_user
            respond_to do |format|
              if @log.save
                @log.team.set_sailing_state!
                format.json { render 'logs/show', status: :created, location: @log }
              else
                format.json { render json: @log.errors, status: :unprocessable_entity }
              end
            end
          end
        end
      end

      def update
        authenticate_user!
        if current_user
          @log = Log.find params[:id]
          team = Team.find @log.team_id
          #if team.people.include? current_user.person || has_organizer_rights?
          if team.people.include? current_user.person
            @log.user_id = current_user.id
            respond_to do |format|
              gen = params.delete(:gen)
              if @log.gen != gen
                # the client tries to update a stale copy, reject
                format.json { render 'logs/show', status: :conflict, location: @log }
              elsif @log.update(log_params)
                @log.team.set_sailing_state!
                format.json { render 'logs/show', status: :ok, location: @log }
              else
                format.json { render json: @log.errors, status: :unprocessable_entity }
              end
            end # /respond_to
          else
            respond_to do |format|
              format.json { render json: 'Du har inte behörighet.', status: :forbidden }
            end
          end
        else
          respond_to do |format|
            format.json { render json: 'Du måste logga in.', status: :unauthorized }
          end
        end # /current_user
      end

      private

      # Never trust parameters from the scary internet, only allow the
      # white list through.
      def log_params
        params.require(:log).permit(:team_id, :time, :user_id, :client, :log_type, :deleted, :point, :data, :gen)
      end

      def authorize_team_member!
        unless current_user
          render status: 401, :json => { :errors => 'Du måste logga in.' }
        else
          team = Team.find @log.team_id
          unless team.people.include? current_user.person
            render status: 403, :json => { :errors => 'Du måste vara besättningsmedlem för att få göra det här.' }
          end
        end
      end

    end
  end
end
