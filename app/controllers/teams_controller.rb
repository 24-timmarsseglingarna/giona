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
    if current_user
      @known_people = current_user.person.friends
    else
      @known_people = Person.all
    end

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
        format.html { render :edit }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end


  def remove_seaman
    person_id = params[:person_id]
    @team = Team.find params[:id]
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
    @team = Team.find params[:id]
    crew_member = CrewMember.find_by person_id: person.id, team_id: @team.id
    @team.set_skipper person
    redirect_to @team, notice: "#{@team.skipper.name unless @team.skipper.blank?} är nu skeppare."
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
      params.require(:team).permit(:race_id, :boat_id, :external_id, :external_system, :name, :boat_name, :boat_class_name, :boat_sail_number, :start_point, :finish_point, :start_number, :plaque_distance, :did_not_start, :did_not_finish, :paid_fee, :active, :offshore, :vacancies, :person_id, :handicap_id, :boat_id, person_ids: [])
    end
end
