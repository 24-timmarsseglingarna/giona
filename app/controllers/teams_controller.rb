class TeamsController < ApplicationController
  include ApplicationHelper
  before_action :set_team, only: [:show, :edit, :update, :check_active!, :destroy, :set_boat, :remove_boat, :remove_seaman, :set_skipper, :set_handicap_type, :remove_handicap]
  before_action :authenticate_user!, :except => [:show, :welcome]
  before_action :check_active!, :except => [:show, :welcome, :index, :new, :create]
  before_action :interims_authenticate!, :except => [:show, :welcome, :index]


  def welcome
    render 'welcome'
  end

  # GET /teams
  # GET /teams.json
  def index
    @teams = nil
    if current_user
      if current_user.person
        @teams = current_user.person.teams.order active: :desc, created_at: :desc
      end
    end
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
  end

  # GET /teams/new
  def new
    @team = Team.new
    if params[:race_id].present?
      @race = Race.is_active(true).find params[:race_id]

      redirect_to races_path, alert: "Börja med att välja regatta eller segling." if @race.blank?

      @team.race = @race
      @team.skipper = current_user.person if current_user
    else
      redirect_to races_path, alert: "Börja med att välja regatta eller segling."
    end
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
    #@srs_keelboats = SrsKeelboat.select_srs_keelboat
    @srs_multihulls = SrsMultihull.all
    @srs_dingies = SrsDingy.all
    @srs_certificates = SrsCertificate.all
    @sxk_certificates = SxkCertificate.all
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
    person = Person.find params[:person_id]
    crew_member = CrewMember.find_by person_id: person.id, team_id: @team.id
    @team.set_skipper person
    unless @team.boat.blank? 
      @team.name = @team.boat.name + '/' + @team.skipper.last_name
    else
      @team.name =  '? /' + team.skipper.last_name
    end
    @team.save!
    redirect_to @team, notice: "#{@team.skipper.name unless @team.skipper.blank?} är nu skeppare."
  end

  def remove_handicap
    @team.handicap = nil
    @team.handicap_type = nil
    @team.save!
    redirect_to @team, notice: "Du behöver välja handikapp för att kunna delta."
  end

  def set_handicap_type
    @team.handicap_type = params[:handicap_type].to_s
    @team.save!
    if ['SrsKeelboat', 'SrsMultihull', 'SrsDingy', 'SrsCertificate', 'SxkCertificate'].include? @team.handicap_type
      redirect_to edit_team_path(:id => @team.id, :section => :handicap)
    else
      redirect_to @team, notice: "Se till att återkomma med mätbrev."
    end
  end

  def remove_boat
    boat_name = @team.boat.name
    @team.boat = nil
    @team.handicap = nil
    @team.handicap_type = nil
    @team.boat_name = nil
    @team.boat_type_name = nil
    @team.boat_sail_number = nil
    @team.save!
    redirect_to @team, notice: "Båten #{boatname unless @boatname.blank?} är nu bortplockad. Välj en annan båt."
  end

  def set_boat
    boat = Boat.find params[:boat_id]
    @team.boat = boat
    @team.boat_name = boat.name
    @team.boat_type_name = boat.boat_type_name
    @team.boat_sail_number = boat.sail_number
    
    if @team.skipper 
      @team.name = boat.name + '/' + @team.skipper.last_name
    else
      @team.name = boat.name + '/ ?'
    end

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
      params.require(:team).permit(:race_id, :boat_id, :external_id, :external_system, :name, :boat_name, :boat_type_name, :boat_sail_number, :start_point, :finish_point, :start_number, :plaque_distance, :did_not_start, :did_not_finish, :paid_fee, :active, :offshore, :vacancies, :person_id, :handicap_id, :handicap_type, :boat_id, boat_attributes: [:id, :name, :boat_type_name, :sail_number, :vhf_call_sign, :ais_mmsi], person_ids: [])
    end

    def interims_authenticate!
      unless has_assistant_rights?
        flash[:alert] = 'Den här funktionen är avstängd pga utvecklingsarbete.'
        redirect_to :back
      end
    end

    def check_active!
      unless @team.active
        flash[:alert] = 'Anmälan/loggboken är arkiverad och kan inte ändras.'
        redirect_to :back  
      end
    end

end
