class OrganizersController < ApplicationController
  include ApplicationHelper

  before_action :set_organizer, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, :except => [:show, :index]

  has_scope :is_active, :type => :boolean, allow_blank: true
  has_scope :has_regatta

  # GET /organizers
  # GET /organizers.json
  def index
    @organizers = apply_scopes(Organizer).all
  end

  # GET /organizers/1
  # GET /organizers/1.json
  def show
  end

  # GET /organizers/new
  def new
    if has_admin_rights?
      @organizer = Organizer.new
    else
      flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
      redirect_to :back
    end
  end

  # GET /organizers/1/edit
  def edit
    unless has_admin_rights?
      flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
      redirect_to :back
    end
  end

  # POST /organizers
  # POST /organizers.json
  def create
    if has_admin_rights?
      @organizer = Organizer.new(organizer_params)
      respond_to do |format|
        if @organizer.save
          format.html { redirect_to @organizer, notice: 'Arrangören las till.' }
          format.json { render :show, status: :created, location: @organizer }
        else
          format.html { render :new }
          format.json { render json: @organizer.errors, status: :unprocessable_entity }
        end
      end
    else
      flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
      redirect_to :back
    end
  end

  # PATCH/PUT /organizers/1
  # PATCH/PUT /organizers/1.json
  def update
    if has_admin_rights?
      respond_to do |format|
        if @organizer.update(organizer_params)
          format.html { redirect_to @organizer, notice: 'Arrangören är uppdaterad.' }
          format.json { render :show, status: :ok, location: @organizer }
        else
          format.html { render :edit }
          format.json { render json: @organizer.errors, status: :unprocessable_entity }
        end
      end
    else
      flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
      redirect_to :back
    end
  end

  # DELETE /organizers/1
  # DELETE /organizers/1.json
  def destroy
    if has_admin_rights?
      @organizer.destroy
      respond_to do |format|
        format.html { redirect_to organizers_url, notice: 'Arrangören togs bort.' }
        format.json { head :no_content }
      end
    else
      flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
      redirect_to :back
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organizer
      @organizer = Organizer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def organizer_params
      params.require(:organizer).permit(:name, :email_from, :name_from, :email_to, :confirmation, :external_id, :external_system)
    end
end
