# coding: utf-8
class LogsController < ApplicationController
  before_action :set_log, only: [:show, :edit, :update, :destroy]

# Right now, don't manage logs from the logs controller (web)
# Logs are only managed through the API. And viewed from the
# teams#show controller, where access is authorized.

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

  # GET /logs/1
  # GET /logs/1.json
  def show
  end

  # GET /logs/new
  def new
    @log = Log.new
  end

  # GET /logs/1/edit
  def edit
  end

  # POST /logs
  # POST /logs.json
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

  # PATCH/PUT /logs/1
  # PATCH/PUT /logs/1.json
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

  # DELETE /logs/1
  # DELETE /logs/1.json
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def log_params
      params.require(:log).permit(:team_id, :time, :user_id, :client, :log_type, :point, :data, :deleted, :gen)
    end

end
