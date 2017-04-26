class BoatTypesController < ApplicationController

  before_action :set_boat_type, only: [:show, :edit, :update, :destroy]
  
  def index
  	@boat_types = BoatType.all
  end

  def show
  end

  def new
    @boat_type = BoatType.new
  end

  def edit
  end

  def create
    @boat_type = BoatType.new(boat_type_params)

    respond_to do |format|
      if @boat_type.save
        format.html { redirect_to @boat_type, notice: 'BoatType was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @boat_type.update(boat_type_params)
        format.html { redirect_to @boat_type, notice: 'BoatType was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @boat_type.destroy
    respond_to do |format|
      format.html { redirect_to boats_url, notice: 'BoatType was successfully destroyed.' }
    end
  end

  private
    def set_boat_type
      @boat_type = BoatType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def boat_type_params
      params.require(type.underscore.to_sym).permit(:name, :handicap, :best_before, :source, :srs, :registry_id, :sail_number, :boat_name, :owner_name, :type, :external_id, :external_system)
    end

end
