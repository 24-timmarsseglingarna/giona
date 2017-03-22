class RegattasController < ApplicationController
  has_scope :is_active, :type => :boolean, allow_blank: true
  has_scope :has_race

  before_action :set_regatta, only: [:show, :edit, :update, :destroy]
 
  # GET /regattas
  # GET /regattas.json
  def index
    @regattas = apply_scopes(Regatta).all
  end

  # GET /regattas/1
  # GET /regattas/1.json
  def show
    @races = @regatta.races
  end

  # GET /regattas/new
  def new
    @regatta = Regatta.new
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
        format.html { redirect_to @regatta, notice: 'Regatta was successfully created.' }
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
        format.html { redirect_to @regatta, notice: 'Regatta was successfully updated.' }
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
      format.html { redirect_to regattas_url, notice: 'Regatta was successfully destroyed.' }
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
      params.require(:regatta).permit(:name, :organizer, :email_from, :name_from, :email_to, :confirmation, :active)
    end
end
