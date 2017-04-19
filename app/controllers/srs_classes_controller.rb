class SrsClassesController < ApplicationController
  before_action :set_srs_class, only: [:show, :edit, :update, :destroy]

  # GET /srs_classes
  # GET /srs_classes.json
  def index
    @srs_classes = SrsClass.all
  end

  # GET /srs_classes/1
  # GET /srs_classes/1.json
  def show
  end

  # GET /srs_classes/new
  def new
    @srs_class = SrsClass.new
  end

  # GET /srs_classes/1/edit
  def edit
  end

  # POST /srs_classes
  # POST /srs_classes.json
  def create
    @srs_class = SrsClass.new(srs_class_params)

    respond_to do |format|
      if @srs_class.save
        format.html { redirect_to @srs_class, notice: 'Srs class was successfully created.' }
        format.json { render :show, status: :created, location: @srs_class }
      else
        format.html { render :new }
        format.json { render json: @srs_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /srs_classes/1
  # PATCH/PUT /srs_classes/1.json
  def update
    respond_to do |format|
      if @srs_class.update(srs_class_params)
        format.html { redirect_to @srs_class, notice: 'Srs class was successfully updated.' }
        format.json { render :show, status: :ok, location: @srs_class }
      else
        format.html { render :edit }
        format.json { render json: @srs_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /srs_classes/1
  # DELETE /srs_classes/1.json
  def destroy
    @srs_class.destroy
    respond_to do |format|
      format.html { redirect_to srs_classes_url, notice: 'Srs class was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_srs_class
      @srs_class = SrsClass.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def srs_class_params
      params.require(:srs_class).permit(:name, :pdf_link, :klassning, :skl, :b, :d, :depl, :srs, :srs_wo_fly, :boat_class_id, :version, :version_name, :import_description, :handicap)
    end
end
