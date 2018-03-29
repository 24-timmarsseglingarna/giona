class TerrainsController < ApplicationController
  include ApplicationHelper
  before_action :set_terrain, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, :except => [:show, :index]
  before_action :authorized?, :except => [:show, :index]

  # GET /terrains
  # GET /terrains.json
  def index
    @terrains = Terrain.all
  end

  # GET /terrains/1
  # GET /terrains/1.json
  def show
  end

  # GET /terrains/new
  def new
    @terrain = Terrain.new
  end

  # GET /terrains/1/edit
  def edit
  end

  # POST /terrains
  # POST /terrains.json
  def create
    @terrain = Terrain.new(terrain_params)

    respond_to do |format|
      if @terrain.save
        format.html { redirect_to @terrain, notice: 'Terrain was successfully created.' }
        format.json { render :show, status: :created, location: @terrain }
      else
        format.html { render :new }
        format.json { render json: @terrain.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /terrains/1
  # PATCH/PUT /terrains/1.json
  def update
    respond_to do |format|
      if @terrain.update(terrain_params)
        format.html { redirect_to @terrain, notice: 'Terrain was successfully updated.' }
        format.json { render :show, status: :ok, location: @terrain }
      else
        format.html { render :edit }
        format.json { render json: @terrain.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /terrains/1
  # DELETE /terrains/1.json
  def destroy
    @terrain.destroy
    respond_to do |format|
      format.html { redirect_to terrains_url, notice: 'Terrain was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_terrain
      @terrain = Terrain.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def terrain_params
      params.require(:terrain).permit(:published, :version_name)
    end

    def authorized?
      if ! has_admin_rights?
        flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
        redirect_to :back
      end
    end
end
