class TeamsController < ApplicationController

  has_scope :from_regatta, :from_race, :from_boat, :has_person
  has_scope :is_active, :type => :boolean, allow_blank: true
  has_scope :did_not_start, :type => :boolean, allow_blank: true
  has_scope :did_not_finish, :type => :boolean, allow_blank: true
  has_scope :has_paid_fee, :type => :boolean, allow_blank: true

  before_action :set_team, only: [:show, :edit, :update, :destroy]

  before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy]

  # GET /teams
  # GET /teams.json
  def index
    @teams = apply_scopes(Team).all
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
  end

  # GET /teams/new
  def new
    @team = Team.new
    @team.race_id = params[:race_id]
    @team.skipper = current_user.person if current_user
    @races = Race.is_active true
  end

  # GET /teams/1/edit
  def edit
    @races = @team.race.regatta.races
    @boat = Boat.new
    @team.boat = @boat
    if current_user
      @known_people = current_user.person.friends
      @known_boats = current_user.person.boats
    else
      @known_people = Person.all
    end
    @boats = Boat.all

  end

  # POST /teams
  # POST /teams.json
  def create
    @team = Team.new(team_params)
    @team.skipper = current_user.person if current_user
    respond_to do |format|
      if @team.save
        format.html { redirect_to @team, notice: 'Deltagaranmälan skapad.' }
        format.json { render :show, status: :created, location: @team }
      else
        format.html { render :new }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    respond_to do |format|
      if @team.update(team_params)
        format.html { redirect_to @team, notice: 'Deltagaranmälan uppdaterad.' }
        format.json { render :show, status: :ok, location: @team }
      else
        format.html { redirect_to @team, alert: 'Nu blev det fel. Uppgiften som du precis lämnade var inte komplett och sparades inte. Det är inte ditt fel. Pröva igen.' }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end


  def remove_seaman
    person_id = params[:person_id]
    set_team
    crew_member = CrewMember.find_by person_id: person_id, team_id: @team.id
    unless crew_member.skipper
      name = crew_member.person.name
      crew_member.destroy!
      redirect_to @team, notice: "Gasten #{name} struken från besättningslistan."
    else
      redirect_to @team, alert: 'Det går inte att stryka skepparen, välj först en ny skeppare.'
    end
  end


  def set_skipper
    set_team
    person = Person.find params[:person_id]
    crew_member = CrewMember.find_by person_id: person.id, team_id: @team.id
    @team.set_skipper person
    redirect_to @team, notice: "#{@team.skipper.name unless @team.skipper.blank?} är nu skeppare."
  end

  def remove_boat
    set_team
    boat_name = @team.boat.name
    @team.boat = nil
    @team.handicap = nil
    @team.boat_name = nil
    @team.boat_type_name = nil
    @team.boat_sail_number = nil
    @team.save!
    redirect_to @team, notice: "Båten #{boatname unless @boatname.blank?} är nu bortplockad. Välj en annan båt."
  end

  def set_boat
    set_team
    boat = Boat.find params[:boat_id]
    @team.boat = boat
    @team.boat_name = boat.name
    @team.boat_type_name = boat.boat_type_name
    @team.boat_sail_number = boat.sail_number
    @team.save!
    redirect_to @team, notice: "Båten #{@team.boat.name unless @team.boat.blank?} är nu vald."
  end


  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    @team.destroy
    respond_to do |format|
      format.html { redirect_to teams_url, notice: 'Deltagaranmälan raderad.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @team = Team.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def team_params
      params.require(:team).permit(:race_id, :boat_id, :external_id, :external_system, :name, :boat_name, :boat_type_name, :boat_sail_number, :start_point, :finish_point, :start_number, :plaque_distance, :did_not_start, :did_not_finish, :paid_fee, :active, :offshore, :vacancies, :person_id, :handicap_id, :boat_id, boat_attributes: [:id, :name, :boat_type_name, :sail_number, :vhf_call_sign, :ais_mmsi], person_ids: [])
    end
end
