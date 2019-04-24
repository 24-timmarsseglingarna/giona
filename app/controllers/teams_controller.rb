class TeamsController < ApplicationController
  include ApplicationHelper
  before_action :set_team, only: [:show, :edit, :update, :check_active!, :destroy, :set_boat, :remove_boat, :add_seaman, :remove_seaman, :set_skipper, :edit_handicap, :update_handicap, :set_handicap, :submit, :draft, :approve, :review]
  before_action :authenticate_user!, :except => [:show, :index, :welcome, :crew]
  before_action :authorize_officer!, only: [:approve, :review]
  before_action :authorize_me!, :except => [:show, :index, :new, :create, :welcome, :crew]
  before_action :check_status!, only: [:show]
  before_action :check_active!, :except => [:show, :welcome, :index, :new, :create, :crew]
  #before_action :interims_authenticate!, :except => [:show, :welcome, :index]
  has_scope :from_regatta, :from_race, :from_boat, :has_person
  has_scope :is_active, :type => :boolean, allow_blank: true
  has_scope :is_archived, :type => :boolean, allow_blank: true


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
          unless params[:is_archived]
            @teams = current_user.person.teams.is_archived(false).order created_at: :desc
          else
            @teams = current_user.person.teams.is_archived(true).order created_at: :desc
          end
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
    if current_user
      # Member of the team or assistant (or higher admin)
      if (has_assistant_rights? || (@team.people.include? current_user.person))
        @logs = @team.logs.order(:time)
      else
        @logs = @team.logs.where(:log_type => ['round', 'seeOtherTeams', 'seeOtherBoats'], deleted: 'false').select('team_id, time, point, data, log_type, deleted').order(:time)
      end
    else
      @logs = @team.logs.where(:log_type => ['round', 'seeOtherTeams', 'seeOtherBoats'], deleted: 'false').select('team_id, time, point, data, log_type, deleted').order(:time)
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
          if current_user.person.teams.from_regatta(@race.regatta.id).present?
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
      TeamMailer.added_crew_member_email(@team, person).deliver
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
    TeamMailer.set_skipper_email(@team).deliver
    redirect_to @team, notice: "#{@team.skipper.name unless @team.skipper.blank?} är nu skeppare."
  end

  def edit_handicap
    # FIXME: create index on team.boat_id
    # normally, this array contains a single value, or is empty.
    @known_handicaps = Array.new
    # get all teams where this boat has participated
    for t in Team.where("boat_id = ?", @team.boat_id).order("created_at DESC")
      h = t.handicap
      if t.id != @team.id and not h.nil?
        if h.registry_id.nil?
          # try to find active with same name
          @known_handicaps = Handicap.
                               where("type = ?", h.type).
                               where("name = ?", h.name).
                               active
        else
          # try to find active with same registry id
          @known_handicaps = Handicap.
                               where("type = ?", h.type).
                               where("registry_id = ?", h.registry_id).
                               active
        end
        if !@known_handicaps.empty?
          # we found a current handicap (or more) for the most recent team,
          # suggest that to the user
          break
        end
      end
    end
    render 'edit_handicap'
  end

  def update_handicap
    old_handicap = @team.handicap
    old_handicap_type = @team.handicap_type
    if params[:step] == '2'
      if @team.update(team_params)
        if !@team.handicap_type
          redirect_to edit_handicap_team_path(@team, step: 1), notice: 'Välj typ av handikapp.'
        else
          if @team.handicap_type != old_handicap_type
            Note.create(team_id: @team.id, user: current_user, description: "#{Handicap.types[@team.handicap_type]}. Valt av #{current_user.to_s}.")
            if @team.state != nil && @team.state != 'draft'
              @team.draft!
            end
          end
          if @team.handicap_type == 'SoonSrsCertificate' || @team.handicap_type == 'SoonSxkCertificate'
            @team.handicap = nil
            @team.save!
            @team.review
            redirect_to @team, notice: "Okej, återkom när du skaffat mätbrev. Då uppdaterar du din anmälan. Tills dess så sätter vi SXK-tal 2,0 så länge."
          else
            if @team.handicap_type != old_handicap_type
              @team.handicap = nil
              @team.save!
            end
            if @team.handicap_type == 'SrsCertificate' || @team.handicap_type == 'SxkCertificate'
              redirect_to edit_handicap_team_path(@team, step: 3), notice: 'Okej, välj nu handikapp för din båt.'
            else
              redirect_to edit_handicap_team_path(@team, step: 3), notice: 'Okej, välj nu handikapp för din båttyp.'
            end
          end
        end
      else
        redirect_to edit_handicap_team_path(@team, step: 1), alert: 'Nu blev det fel. Det är inte ditt fel. Försök igen.'
      end
    elsif params[:step] == '3'
      if @team.update(team_params)
        if @team.handicap_type.present?
          if @team.handicap.present?
            if @team.handicap_type == @team.handicap.type
              @team.review
              if @team.handicap != old_handicap
                Note.create(team_id: @team.id, user: current_user, description: "Handikapp satt till #{@team.handicap.description} (#{@team.handicap.id}) av #{current_user.to_s}.")
                if @team.state != nil && @team.state != 'draft'
                  @team.draft!
                  notice = "Handikapp satt. Du behöver skicka in anmälan för granskning igen."
                else
                  notice = "Handikapp satt."
                end
              end
              redirect_to @team, notice: notice
            else
              redirect_to edit_handicap_team_path(@team, step: 1), alert: 'Nu blev det fel. Uppgiften som du precis lämnade var inte komplett och sparades inte. Det är inte ditt fel. Pröva igen.'
            end
          else
            redirect_to edit_handicap_team_path(@team, step: 2), alert: 'Du behöver välja handikapp.'
          end
        else
          redirect_to edit_handicap_team_path(@team, step: 1), alert: 'Nu blev det fel. Uppgiften som du precis lämnade var inte komplett och sparades inte. Det är inte ditt fel. Pröva igen.'
        end
      else
        redirect_to edit_handicap_team_path(@team, step: 1), alert: 'Nu blev det fel. Uppgiften som du precis lämnade var inte komplett och sparades inte. Det är inte ditt fel. Pröva igen.'
      end
    else
      redirect_to edit_handicap_team_path(@team, step: 1), notice: "Vilken typ av handikapp ska du använda?"
    end
  end

  def set_handicap
    old_handicap = @team.handicap
    old_handicap_type = @team.handicap_type
    new_handicap = Handicap.find params[:handicap_id]
    if new_handicap.nil?
        redirect_to edit_handicap_team_path(@team, step: 1), alert: 'Nu blev det fel. Uppgiften som du precis lämnade var inte komplett och sparades inte. Det är inte ditt fel. Pröva igen.'
    else
      @team.handicap = new_handicap
      @team.handicap_type = new_handicap.type
      if @team.handicap != old_handicap
        Note.create(team_id: @team.id, user: current_user, description: "Handikapp satt till #{@team.handicap.description} (#{@team.handicap.id}) av #{current_user.to_s}.")
        if @team.state != nil && @team.state != 'draft'
          @team.draft!
          notice = "Handikapp satt. Du behöver skicka in anmälan för granskning igen."
        else
          notice = "Handikapp satt."
        end
      end
      @team.save!
      redirect_to @team, notice: notice
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
      TeamMailer.submitted_team_email(@team).deliver
      TeamMailer.inform_officer_email(@team).deliver
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
        if has_officer_rights? && @team.approved?
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
      TeamMailer.approved_team_email(@team).deliver
      redirect_to @team, notice: 'Anmälan är godkänd.'
    else
      redirect_to @team, alert: "Det går bara att godkänna en anmälan som är i status 'inskickad'."
    end
  end

  def review
    if @team.signed?
      @team.reviewed!
      Note.create(team_id: @team.id, user: current_user, description: "Loggbok granskad av #{current_user.to_s}.")
      redirect_to @team, notice: 'Loggboken är granskad.'
    else
      redirect_to @team, alert: "Det går bara att granska en loggbok som är i status 'inskickad' eller 'godkänd'."
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
      params.require(:team).permit(:race_id, :boat_id, :external_id, :external_system, :name, :boat_name, :boat_type_name, :boat_sail_number, :start_point, :finish_point, :start_number, :plaque_distance, :active, :offshore, :vacancies, :person_id, :handicap_id, :handicap_type, :state, :sailing_state, :boat_id, boat_attributes: [:id, :name, :boat_type_name, :sail_number, :vhf_call_sign, :ais_mmsi], person_ids: [])
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

    def authorize_officer!
      unless current_user
        flash[:alert] = 'Du behöver logga in.'
        redirect_to :back
      else
        unless has_officer_rights?
          flash[:alert] = 'Du behöver ha funktionärsbehörighet.'
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

    def check_status!
      @status = @team.review
      if @team.draft? && current_user
        if ! @status.blank?
          flash.now['danger'] = 'Du behöver komplettera din anmälan nedan innan du kan skicka in den.'
        else
          flash.now['alert'] = 'Du behöver nu skicka in din anmälan nedan.'
        end
      end
    end

end
