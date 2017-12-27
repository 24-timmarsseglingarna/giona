# coding: utf-8
module Api
  module V1
    class LogsController < ApiController

      has_scope :from_team
      has_scope :from_regatta
      has_scope :updated_after
      has_scope :has_type
      has_scope :not_client
      has_scope :not_team

      def index
        @logs = apply_scopes(Log).all
        render 'logs/index'
      end

      def show
        @log = Log.find(params[:id])
        render 'logs/show'
      end

      def create
        # not correct - how do I call the other logs_controller?
        @log = Log.new(log_params)
        respond_to do |format|
          if @log.save
            format.json { render 'logs/show', status: :created, location: @log }
          else
            format.json { render json: @log.errors,
                                 status: :unprocessable_entity }
          end
        end
      end

      def update
        # not correct - how do I call the other logs_controller?
        @log = Log.find(params[:id])
        respond_to do |format|
          gen = params.delete(:gen)
          if @log.gen != gen
            # the client tries to update a stale copy, reject
            format.json { render 'logs/show', status: :conflict,
                                 location: @log }
          elsif @log.update(log_params)
            format.json { render 'logs/show', status: :ok, location: @log }
          else
            format.json { render json: @log.errors,
                                 status: :unprocessable_entity }
          end
        end
      end

      private

      # Never trust parameters from the scary internet, only allow the
      # white list through.
      def log_params
        params.require(:log)
          .permit(:team_id, :time, :user_id, :client, :log_type,
                  :deleted, :point, :data)
      end

    end
  end
end
