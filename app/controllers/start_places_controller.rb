class StartPlacesController < ApplicationController
  before_action :set_start_place, only: [:show, :edit, :update, :destroy]

  # GET /start_places
  # GET /start_places.json
  def index
    @start_places = StartPlace.all
  end

  # GET /start_places/1
  # GET /start_places/1.json
  def show
  end

  # GET /start_places/new
  def new
    @start_place = StartPlace.new
  end

  # GET /start_places/1/edit
  def edit
  end

  # POST /start_places
  # POST /start_places.json
  def create
    @start_place = StartPlace.new(start_place_params)

    respond_to do |format|
      if @start_place.save
        format.html { redirect_to @start_place, notice: 'Start place was successfully created.' }
        format.json { render :show, status: :created, location: @start_place }
      else
        format.html { render :new }
        format.json { render json: @start_place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /start_places/1
  # PATCH/PUT /start_places/1.json
  def update
    respond_to do |format|
      if @start_place.update(start_place_params)
        format.html { redirect_to @start_place, notice: 'Start place was successfully updated.' }
        format.json { render :show, status: :ok, location: @start_place }
      else
        format.html { render :edit }
        format.json { render json: @start_place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /start_places/1
  # DELETE /start_places/1.json
  def destroy
    @start_place.destroy
    respond_to do |format|
      format.html { redirect_to start_places_url, notice: 'Start place was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_start_place
      @start_place = StartPlace.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def start_place_params
      params.require(:start_place).permit(:organizer_id, :number)
    end
end
