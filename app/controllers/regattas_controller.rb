class RegattasController < ApplicationController
  include ApplicationHelper

  has_scope :is_active, :type => :boolean, allow_blank: true
  has_scope :has_race, :from_organizer

  before_action :authenticate_user!, :except => [:show, :index]
  before_action :authorized?, :except => [:show, :index]

  before_action :set_regatta, only: [:show, :edit, :update, :destroy]

  # GET /regattas
  # GET /regattas.json
  def index
    @regattas = apply_scopes(Regatta).all
  end

  # GET /regattas/1
  # GET /regattas/1.json
  def show
    @races = @regatta.races
    if has_organizer_rights?
      @teams = @regatta.teams
    else
      @teams = @regatta.teams.where("state > ?", 0)
    end
  end

  # GET /regattas/new
  def new
    @regatta = Regatta.new
    if params[:organizer_id].present? or @regatta.organizer_id.present?
      organizer = Organizer.find params[:organizer_id]
      @regatta.organizer_id = organizer.id
      @regatta.email_from = organizer.email_from
      @regatta.name_from = organizer.name_from
      @regatta.email_to = organizer.email_to
      @regatta.confirmation = organizer.confirmation
    end
  end

  # GET /regattas/1/edit
  def edit
  end

  # POST /regattas
  # POST /regattas.json
  def create
    @regatta = Regatta.new(regatta_params)
    respond_to do |format|
      if @regatta.save
        format.html { redirect_to @regatta, notice: 'Regattan är skapad.' }
        format.json { render :show, status: :created, location: @regatta }
      else
        format.html { render :new }
        format.json { render json: @regatta.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /regattas/1
  # PATCH/PUT /regattas/1.json
  def update
    respond_to do |format|
      if @regatta.update(regatta_params)
        format.html { redirect_to @regatta, notice: 'Regattan är ändrad.' }
        format.json { render :show, status: :ok, location: @regatta }
      else
        format.html { render :edit }
        format.json { render json: @regatta.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /regattas/1
  # DELETE /regattas/1.json
  def destroy
    @regatta.destroy
    respond_to do |format|
      format.html { redirect_to regattas_url, notice: 'Regattan är raderad.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_regatta
      @regatta = Regatta.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def regatta_params
      params.require(:regatta).permit(:name, :terrain_id,  :organizer_id, :email_from, :name_from, :email_to, :confirmation, :active, :web_page, :external_id, :external_system)
    end

    def authorized?
      if ! has_organizer_rights?
        flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
        redirect_to :back
      end
    end

end
