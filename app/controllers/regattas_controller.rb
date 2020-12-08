class RegattasController < ApplicationController
  include ApplicationHelper

  has_scope :is_active, :type => :boolean, allow_blank: true
  has_scope :has_race, :from_organizer

  before_action :authenticate_user!, :except => [:show, :start_list, :result, :index]
  before_action :authorized?, :except => [:show, :start_list, :result, :index, :email_list]
  before_action :authorized_assistant?, :only => [:email_list]

  before_action :set_regatta, only: [:show, :start_list, :result, :email_list, :edit, :update, :destroy]

  # GET /regattas
  # GET /regattas.json
  def index
    @regattas = apply_scopes(Regatta).all
  end

  # GET /regattas/1
  # GET /regattas/1.json
  def show
    @races = @regatta.races
    if has_assistant_rights?
      @teams = @regatta.teams
    else
      @teams = @regatta.teams.where("state > ?", 0)
    end
    file_name = "Anmalningsrapport--#{@regatta.name}--exporterad--#{DateTime.now.iso8601}".parameterize
    respond_to do |format|
      format.html
      format.xlsx {
          response.headers['Content-Disposition'] = "attachment; filename=#{file_name}.xlsx"
            }
    end
  end

  def start_list
    render 'start_list'
  end

  def result
    @rs = []
    for @race in @regatta.races.order(:start_from)
      logbooks = []
      @race.teams.is_visible().each do |team|
        logbook = helpers.get_logbook(team, team.logs.order(:time, :id))
        logbook[:team] = team
        notes = []
        if (logbook[:compensation_dist] != 0)
          notes.push("Tillägg undsättning: #{logbook[:compensation_dist].round(1)} M")
        end
        if (logbook[:admin_dist] != 0)
          notes.push("Distansavdrag: #{logbook[:admin_dist].round(1)} M")
        end
        logbook[:notes] = notes
        route = ""
        for e in logbook[:entries]
          if e[:prev_point]
            route << "&nbsp;&nbsp;-&nbsp; "
          end
          if e[:log].point
            route << e[:log].point.to_s
            if e[:distance]
              route << "&nbsp;(#{e[:distance]})"
            elsif e[:prev_point]
              # this is an invalid leg
              route << "&nbsp;(0)"
            end
          end
        end
        logbook[:route] = route
        # if the regatta is still active (we have a preliminary result), push
        # all logbooks, even incomplete ones
        if (logbook[:plaque_dist] != 0) || !logbook[:state].nil? || @regatta.active
          logbooks.push(logbook)
        end
      end
      logbooks = logbooks.sort{ |a,b| -helpers.compare_logbook(a,b) }
      i = 1
      for logbook in logbooks
        logbook[:place] = i
        i = i + 1
      end
      r = { :race => @race,
            :logbooks => logbooks}
      @rs.push(r)
    end
    render 'result'
  end

  def email_list
    @people = @regatta.people
    render 'email_list'
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
      params.require(:regatta).permit(:name, :description, :terrain_id,  :organizer_id, :email_from, :name_from, :email_to, :confirmation, :active, :web_page, :external_id, :external_system)
    end

    def authorized?
      if ! has_officer_rights?
        flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
        redirect_to :back
      end
    end

    def authorized_assistant?
      if ! has_assistant_rights?
        flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
        redirect_to :back
      end
    end
end
