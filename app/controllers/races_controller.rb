class RacesController < ApplicationController
  before_action :set_race, only: [:show, :edit, :update, :destroy]
  has_scope :from_organizer, :from_regatta, :has_team, :has_period
  has_scope :is_active, :type => :boolean, allow_blank: true

  # GET /races
  # GET /races.json
  def index
    @races = apply_scopes(Race).all.order(regatta_id: :asc, period: :asc)
    if params[:organizer_id].present?
      @organizers = Organizer.where("id = ?", params[:organizer_id])
    else
      @organizers = Organizer.is_active(true)
    end
  end

  # GET /races/1
  # GET /races/1.json
  def show
  end

  # GET /races/new
  def new
    if params[:regatta_id].blank?
      redirect_to regattas_path, alert: 'Seglingar kan bara skapas från regattasidor.'
    else   
      @race = Race.new
      @race.period = params[:period] 
      regatta = Regatta.find params[:regatta_id]
      @race.regatta_id = regatta.id 
    end
  end

  # GET /races/1/edit
  def edit
  end

  # POST /races
  # POST /races.json
  def create
    @race = Race.new(race_params)
    @race.start_to = @race.start_from if( @race.start_to.blank? && @race.start_from.present?)
    respond_to do |format|
      if @race.save
        format.html { redirect_to @race, notice: 'Race was successfully created.' }
        format.json { render :show, status: :created, location: @race }
      else
        format.html { render :new }
        format.json { render json: @race.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /races/1
  # PATCH/PUT /races/1.json
  def update
    respond_to do |format|
      if @race.update(race_params)
        format.html { redirect_to @race, notice: 'Race was successfully updated.' }
        format.json { render :show, status: :ok, location: @race }
      else
        format.html { render :edit }
        format.json { render json: @race.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /races/1
  # DELETE /races/1.json
  def destroy
    @race.destroy
    respond_to do |format|
      format.html { redirect_to races_url, notice: 'Race was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_race
      @race = Race.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def race_params
      params.require(:race).permit(:start_from, :start_to, :period, :common_finish, :mandatory_common_finish, :external_system, :external_id, :regatta_id, :description)
    end
end
