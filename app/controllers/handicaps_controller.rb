class HandicapsController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_user!
  before_action :authorized?, :except => [:show, :index]

  before_action :set_handicap, only: [:show, :edit, :update, :destroy]
  before_action :set_type

  # GET /handicaps
  # GET /handicaps.json
  def index
    @handicaps = type_class.all
  end

  # GET /handicaps/1
  # GET /handicaps/1.json
  def show
  end

  # GET /handicaps/new
  def new
    @handicap = Handicap.new
  end

  # GET /handicaps/1/edit
  def edit
  end

  # POST /handicaps
  # POST /handicaps.json
  def create
    @handicap = Handicap.new(handicap_params)

    respond_to do |format|
      if @handicap.save
        format.html { redirect_to @handicap, notice: 'Handikappet är upplagt.' }
        format.json { render :show, status: :created, location: @handicap }
      else
        format.html { render :new }
        format.json { render json: @handicap.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /handicaps/1
  # PATCH/PUT /handicaps/1.json
  def update
    respond_to do |format|
      if @handicap.update(handicap_params)
        format.html { redirect_to @handicap, notice: 'Handikappet är uppdaterat.' }
        format.json { render :show, status: :ok, location: @handicap }
      else
        format.html { render :edit }
        format.json { render json: @handicap.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /handicaps/1
  # DELETE /handicaps/1.json
  def destroy
    @handicap.destroy
    respond_to do |format|
      format.html { redirect_to handicaps_url, notice: 'Handikappet är borttaget.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_handicap
      @handicap = type_class.find(params[:id])
    end

    def set_type 
       @type = type 
    end

    def type 
        Handicap.types.include?(params[:type]) ? params[:type] : "Handicap"
    end

    def type_class 
        type.constantize 
    end    

    # Never trust parameters from the scary internet, only allow the white list through.
    def handicap_params
      params.require(@handicap.type.underscore.to_sym).permit(:name, :handicap, :best_before, :source, :srs, :registry_id, :sail_number, :boat_name, :owner_name, :external_system, :external_id)
    end

    def authorized?
      if ! has_admin_rights? 
        flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
        redirect_to :back
      end  
    end

end