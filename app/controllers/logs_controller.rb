# coding: utf-8
class LogsController < ApplicationController
  before_action :set_log, only: [:show, :edit, :update]

## FIXME:
##   must be authenticated and part of the team in order to
##     - create/update/delete a log entry
##     - read full log entry
##   any user should be able to read summary log entried - how do
##   you let a query parameter (?summary=true) influence which fields
##   are returned?  should return just :id, :point, :time, :updated_at
##   where :type == 'round'
##   This is currently emulated by the client sending has_type + not_client

#  before_action :authenticate_user!, :except => [:show, :welcome]
#  before_action :interims_authenticate!, :except => [:show, :welcome, :index]

  has_scope :from_team
  has_scope :from_regatta
  has_scope :updated_after
  has_scope :has_type
  has_scope :not_client
  has_scope :not_team

  def index
    @logs = apply_scopes(Log).all.order(team_id: :asc, time: :asc)

#    if params[:team_id].present?
#      @logs = Log.where("team_id = ?", params[:team_id]).order(time: :asc)
#    else
#      @logs = Log.all.order(team_id: :asc, time: :asc)
#    end
  end

  def show
  end

  def create
    @log = Log.new(log_params)
    respond_to do |format|
      if @log.save
        format.html { redirect_to @log, notice: 'Loggen har lagts till.' }
        format.json { render :show, status: :created, location: @log }
      else
        format.html { render :new }
        format.json { render json: @log.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @log.update(log_params)
        format.html { redirect_to @log,
                      notice: 'Uppgifterna om loggen är uppdaterade.' }
        format.json { render :show, status: :ok, location: @log }
      else
        format.html { render :edit }
        format.json { render json: @log.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @log.destroy
    respond_to do |format|
      format.html { redirect_to logs_url, notice: 'Loggen raderad.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_log
      @log = Log.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the
    # white list through.
    def log_params
      params.require(:log)
        .permit(:team_id, :time, :user_id, :client, :log_type,
                :deleted, :point, :data)
    end

end
