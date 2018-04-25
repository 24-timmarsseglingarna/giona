class TeamsController < ApplicationController
  include ApplicationHelper
  before_action :set_team, only: [:show, :edit, :update, :check_active!, :destroy, :set_boat, :remove_boat, :add_seaman, :remove_seaman, :set_skipper, :set_handicap_type, :remove_handicap, :submit, :draft, :approve]
  before_action :authenticate_user!, :except => [:show, :index, :welcome, :crew]
  before_action :authorize_organizer!, only: [:approve]
  before_action :authorize_me!, :except => [:show, :index, :new, :create, :welcome, :crew]
  before_action :check_active!, :except => [:show, :welcome, :index, :new, :create, :crew]
  #before_action :interims_authenticate!, :except => [:show, :welcome, :index]
  has_scope :from_regatta, :from_race, :from_boat, :has_person
  has_scope :is_active, :type => :boolean, allow_blank: true


  def welcome
    @races = apply_scopes(Race).all.order(regatta_id: :asc, period: :asc)
    if params[:organizer_id].present?
      @organizers = Organizer.where("id = ?", params[:organizer_id])
    else
      @organizers = Organizer.is_active(true).distinct
    end
    render 'welcome'
  end

  def crew
    render 'crew'
  end

  # GET /teams
  # GET /teams.json
  def index
    @teams = nil
    if current_user
      if current_user.person
        if current_user.person.teams.present?
          @teams = current_user.person.teams.is_archived(false).order created_at: :desc
        end
      end
    end
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    @status = @team.review
    if params[:notes].present?
      @notes = @team.notes.reverse
    else
      @notes = @team.notes.last(5).reverse
    end
  end

  # GET /teams/new
  def new
    @team = Team.new
    if params[:race_id].present?
      @race = Race.is_active(true).find params[:race_id]
      redirect_to races_path, alert: "Börja med att välja regatta eller segling." if @race.blank?
      @team.race = @race
      if current_user
        if current_user.person.present?
          @team.skipper = current_user.person
          if @race.regatta.people.include? current_user.person
            @teams = current_user.person.teams.is_active(true).from_regatta(@race.regatta.id).order created_at: :desc # TODO refactor to life cycle state
            flash[:notice] = 'Du är redan anmäld till den här regattan.'
          end
        end
      end
    else
      redirect_to races_path, alert: "Börja med att välja regatta eller segling."
    end
  end

  # GET /teams/1/edit
  def edit
    @races = @team.race.regatta.races
    @starts = @team.race.starts.reject(&:empty?)
    @boat = Boat.new
    @team.boat = @boat
    @people = Person.all
    @known_people = Array.new
    if current_user
      for person in current_user.person.friends
        @known_people << person unless @team.people.include? person
      end
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
    if current_user
      if current_user.person.present?
        @team.skipper = current_user.person
        @team.set_name
        respond_to do |format|
          if @team.save
            Note.create(team_id: @team.id, user: current_user, description: "Anmälan skapad av #{current_user.to_s}.")
            @team.skipper.update_attribute 'skip_validation', false
            TeamMailer.created_team_email(@team).deliver
            format.html { redirect_to @team, notice: 'Deltagaranmälan skapad. Vi skickar ett mejl med länk till din anmälan. Komplettera nu anmälan och skicka in den.' }
            format.json { render :show, status: :created, location: @team }
          else
            format.html { render :new }
            format.json { render json: @team.errors, status: :unprocessable_entity }
          end
        end
      else
        redirect_to new_person_path(:add_me => true), notice: "Först behöver vi dina kontaktuppgiter."
      end
    end
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    old_boat = @team.boat
    old_vacancies = @team.vacancies
    old_handicap = @team.handicap
    old_start_point = @team.start_point
    old_offshore = @team.offshore
    old_race = @team.race
    description = ''
    respond_to do |format|
      if @team.update(team_params)
        if @team.race != old_race
          description += "Segling ändrad till #{@team.race.name} (#{@team.race.id}) av #{current_user.to_s}."
          unless @team.race.starts.include? @team.start_point.to_s
            @team.start_point = nil
            @team.save!
            flash[:alert] = 'Startplatsen du tidigare valt kan inte användas vid den här seglingen. Välj en ny.'
          end
        end
        if @team.vacancies != old_vacancies
          description += "Gastefterlysning ändrad av #{current_user.to_s}."
        end
        if (@team.handicap != old_handicap) && @team.handicap.present?
          description += "Handikapp satt till #{@team.handicap.description} (#{@team.handicap.id}) av #{current_user.to_s}."
        end
        if @team.start_point != old_start_point
          description += "Startplats satt till #{@team.start_point} av #{current_user.to_s}."
        end
        if @team.offshore != old_offshore
          description += "Havs-/kustsegling satt till #{@team.offshore_name} av #{current_user.to_s}."
        end
        if @team.boat != old_boat
          @team.set_boat @team.boat
          @team.set_name
          @team.save!
        end
        if description.present?
          Note.create(team_id: @team.id, user: current_user, description: description)
        end
        format.html { redirect_to @team, notice: 'Deltagaranmälan uppdaterad.' }
        format.json { render :show, status: :ok, location: @team }
      else
        format.html { redirect_to @team, alert: 'Nu blev det fel. Uppgiften som du precis lämnade var inte komplett och sparades inte. Det är inte ditt fel. Pröva igen.' }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_seaman
    person = Person.find params[:person_id]
    if CrewMember.find_by( person_id: person.id, team_id: @team.id).blank?
      crew_member = CrewMember.create person_id: person.id, team_id: @team.id
      Note.create(team_id: @team.id, user: current_user, description: "Gast #{person.name} (#{person.id}) tillagd av #{current_user.to_s}.")
      person.update_attribute 'skip_validation', false
      redirect_to @team, notice: "Gasten #{person.name} tillagd i besättningslistan."
    else
      redirect_to @team, notice: "Gasten #{person.name} fanns redan i besättningslistan."
    end
  end

  def remove_seaman
    person_id = params[:person_id]
    crew_member = CrewMember.find_by person_id: person_id, team_id: @team.id
    unless crew_member.skipper
      name = crew_member.person.name
      crew_member.destroy!
      Note.create(team_id: @team.id, user: current_user, description: "Gast #{name} (#{person_id}) borttagen av #{current_user.to_s}.")
      redirect_to @team, notice: "Gasten #{name} struken från besättningslistan."
    else
      redirect_to @team, alert: 'Det går inte att stryka skepparen, välj först en ny skeppare.'
    end
  end


  def set_skipper
    person = Person.find params[:person_id]
    crew_member = CrewMember.find_by person_id: person.id, team_id: @team.id
    @team.set_skipper person
    @team.set_name
    @team.save!
    Note.create(team_id: @team.id, user: current_user, description: "#{person.name} (#{person.id}) utsedd till skeppare av #{current_user.to_s}.")
    @team.skipper.update_attribute 'skip_validation', false
    redirect_to @team, notice: "#{@team.skipper.name unless @team.skipper.blank?} är nu skeppare."
  end

  def remove_handicap
    @team.handicap = nil
    @team.handicap_type = nil
    @team.save!
    Note.create(team_id: @team.id, user: current_user, description: "Handikapp borttaget av #{current_user.to_s}.")
    if @team.submitted?
      @team.draft!
      flash[:alert] = "Deltagaranmälan har nu status 'utkast'. Du behöver skicka in den igen."
      Note.create(team_id: @team.id, user: current_user, description: "Anmälan drogs tillbaka eftersom handikappet togs bort av #{current_user.to_s}.")
    end
    redirect_to @team, notice: "Du behöver välja handikapp för att kunna delta."
  end

  def set_handicap_type
    @team.handicap_type = params[:handicap_type].to_s
    @team.save!
    Note.create(team_id: @team.id, user: current_user, description: "Handikapptyp #{@team.handicap_type} satt av #{current_user.to_s}.")
    if ['SrsKeelboat', 'SrsMultihull', 'SrsDingy', 'SrsCertificate', 'SxkCertificate'].include? @team.handicap_type
      redirect_to edit_team_path(:id => @team.id, :section => :handicap)
    else
      redirect_to @team, notice: "Se till att återkomma med mätbrev."
    end
  end

  def remove_boat
    boat_name = @team.boat.name
    boat_id = @team.boat.id
    @team.boat = nil
    @team.handicap = nil
    @team.handicap_type = nil
    @team.boat_name = nil
    @team.boat_type_name = nil
    @team.boat_sail_number = nil
    @team.save!
    if @team.submitted?
      @team.draft!
      flash[:alert] = "Deltagaranmälan har nu status 'utkast'. Du behöver skicka in den igen."
      Note.create(team_id: @team.id, user: current_user, description: "Anmälan drogs tillbaka eftersom båten togs bort av #{current_user.to_s}.")
    end
    Note.create(team_id: @team.id, user: current_user, description: "Båt #{boat_name} (#{boat_id}) bortvald av #{current_user.to_s}.")
    redirect_to @team, notice: "Båten #{boatname unless @boatname.blank?} är nu bortplockad. Välj en annan båt."
  end

  def set_boat
    boat = Boat.find params[:boat_id]
    @team.boat = boat
    @team.set_boat boat
    @team.set_name
    @team.save!
    Note.create(team_id: @team.id, user: current_user, description: "Båt #{boat.name} (#{boat.id}) vald av #{current_user.to_s}.")
    redirect_to @team, notice: "Båten #{@team.boat.name unless @team.boat.blank?} är nu vald."
  end

  def submit
    if @team.draft?
      @team.start_number = @team.race.regatta.next_start_number if @team.start_number.nil?
      @team.submitted!
      Note.create(team_id: @team.id, user: current_user, description: "Deltagaranmälan inskickad av #{current_user.to_s}.")
      redirect_to @team, notice: 'Toppen! Nu är anmälan inskickad till arrangören.'
    else
      redirect_to @team, alert: 'Det går bara att skicka in anmälan som är i status utkast.'
    end
  end

  def draft
    if @team.submitted?
      @team.draft!
      Note.create(team_id: @team.id, user: current_user, description: "Deltagaranmälan återdragen av #{current_user.to_s}.")
      redirect_to @team, notice: 'Anmälan är återdragen. Du kan ändra i den. Skicka in den om du vill vara anmäld.'
    else
        if has_organizer_rights? && @team.approved?
          @team.draft!
          Note.create(team_id: @team.id, user: current_user, description: "Deltagaranmälan återdragen av #{current_user.to_s}.")
          redirect_to @team, notice: 'Anmälan är återdragen. Den kan ändras och godkännas igen.'
      else
        redirect_to @team, alert: "Det går bara att skicka in anmälan som är i status 'inskickad'."
      end
    end
  end

  def approve
    if @team.submitted?
      @team.approved!
      Note.create(team_id: @team.id, user: current_user, description: "Deltagaranmälan godkänd av #{current_user.to_s}.")
      redirect_to @team, notice: 'Anmälan är godkänd och nu synlig i startlistan.'
    else
      redirect_to @team, alert: "Det går bara att godkänna en anmälan som är i status 'inskickad'."
    end
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
      params.require(:team).permit(:race_id, :boat_id, :external_id, :external_system, :name, :boat_name, :boat_type_name, :boat_sail_number, :start_point, :finish_point, :start_number, :plaque_distance, :did_not_start, :did_not_finish, :paid_fee, :active, :offshore, :vacancies, :person_id, :handicap_id, :handicap_type, :state, :boat_id, boat_attributes: [:id, :name, :boat_type_name, :sail_number, :vhf_call_sign, :ais_mmsi], person_ids: [])
    end

    def authorize_me!
      unless current_user
        flash[:alert] = 'Du behöver logga in.'
        redirect_to :back
      else
        unless (has_assistant_rights? || (@team.people.include? current_user.person))
          flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter. Du behöver tillhöra besättningen eller ha särskild behörighet.'
          redirect_to :back
        end
      end
    end

    def authorize_organizer!
      unless current_user
        flash[:alert] = 'Du behöver logga in.'
        redirect_to :back
      else
        unless has_organizer_rights?
          flash[:alert] = 'Du behöver ha arrangörsbehörighet.'
          redirect_to :back
        end
      end
    end

    def interims_authenticate!
      unless has_assistant_rights?
        flash[:alert] = 'Den här funktionen är avstängd pga utvecklingsarbete.'
        redirect_to :back
      end
    end

    def check_active!
      if @team.archived?
        flash[:alert] = 'Anmälan/loggboken är arkiverad och kan inte ändras.'
        redirect_to :back
      end
    end

end
