# coding: utf-8
module Api
  module V1
    class LogsController < ApiController
      acts_as_token_authentication_handler_for User, except: [:index, :show]
      has_scope :has_team
      has_scope :from_team
      has_scope :from_regatta
      has_scope :updated_after
      has_scope :has_type
      has_scope :not_client
      has_scope :not_team

      def index
        @logs = apply_scopes(Log).all.select(:team_id, :time, :user_id, :client, :log_type, :deleted, :point, :gen).order(time: :asc, id: :asc)
        if params[:from_team]
          if user_signed_in?
            team = Team.find params[:from_team].to_i
            if (team.people.include? current_user.person) || has_officer_rights?
              # team members gets all logentries, including "deleted"
              @logs = apply_scopes(Log).all.order(time: :asc, id: :asc)
              render 'logs/index'
            else
              @logs = apply_scopes(Log).all.where(log_type: 'round', deleted: false).order(time: :asc, id: :asc)
              render 'logs/index_filtered'
            end
          else
            @logs = apply_scopes(Log).all.where(log_type: 'round', deleted: false).order(time: :asc, id: :asc)
          end
        else
          if user_signed_in? && has_officer_rights?
            # officers can view all non-deleted log entries
            @logs = apply_scopes(Log).all.where(deleted: false).order(time: :asc, id: :asc)
            render 'logs/index'
          else
            # others can (currently) view only type "round"
            @logs = apply_scopes(Log).all.where(log_type: 'round', deleted: false).order(time: :asc, id: :asc)
            render 'logs/index_filtered'
          end
        end
      end

      def show
        @log = Log.find params[:id]
        if user_signed_in?
          team = Team.find @log.team_id
          if (team.people.include? current_user.person) || has_officer_rights?
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
          if (team.people.include? current_user.person) || has_officer_rights?
            if team.is_signed && !has_officer_rights?
              render json: {
                       error: "Loggen är signerad och kan inte ändras.",
                       status: :forbidden
                     }, status: :forbidden
            elsif @log.type == 'AdminLog' && !has_officer_rights?
              # "should not happen", but we enforce strict access control
              render json: {
                       error: "Du saknar behörighet.",
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
          else
            render json: {
              error: "Du har inte behörighet, det har bara besättningsmedlemmar.",
              status: :forbidden
              }, status: :forbidden
          end
        end
      end

      def update
        authenticate_user!
        if current_user
          @log = Log.find params[:id]
          team = Team.find @log.team_id
          if (team.people.include? current_user.person) || has_officer_rights?
            if team.is_signed && !has_officer_rights?
              render json: {
                       error: "Loggen är signerad och kan inte ändras.",
                       status: :forbidden
                     }, status: :forbidden
            elsif @log.type == 'AdminLog' && !has_officer_rights?
              # "should not happen", but we enforce strict access control
              render json: {
                       error: "Du saknar behörighet.",
                       status: :forbidden
                     }, status: :forbidden
            else
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
            end
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
        p = params.require(:log).permit(:type, :team_id, :time, :user_id, :client, :log_type, :deleted, :point, :data, :gen)
        if !p.has_key?(:type)
          # add the type if not present; this can be from an old app
          p.merge!({ type: 'TeamLog' })
        else
          p
        end
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

      # FIXME: copy-and-pasted from application_helper
      def has_officer_rights?
        if current_user
          if current_user.role == 'officer' || current_user.role == 'admin'
            true
          else
            false
          end
        else
          false
        end
      end

    end
  end
end
