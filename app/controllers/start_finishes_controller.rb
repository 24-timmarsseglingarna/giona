class StartFinishesController < ApplicationController
  before_action :set_start_finish, only: [:show, :edit, :update, :destroy]

  # GET /start_finishes
  # GET /start_finishes.json
  def index
    @start_finishes = StartFinish.all
  end

  # GET /start_finishes/1
  # GET /start_finishes/1.json
  def show
  end

  # GET /start_finishes/new
  def new
    @start_finish = StartFinish.new
  end

  # GET /start_finishes/1/edit
  def edit
  end

  # POST /start_finishes
  # POST /start_finishes.json
  def create
    @start_finish = StartFinish.new(start_finish_params)

    respond_to do |format|
      if @start_finish.save
        format.html { redirect_to @start_finish, notice: 'Start finish was successfully created.' }
        format.json { render :show, status: :created, location: @start_finish }
      else
        format.html { render :new }
        format.json { render json: @start_finish.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /start_finishes/1
  # PATCH/PUT /start_finishes/1.json
  def update
    respond_to do |format|
      if @start_finish.update(start_finish_params)
        format.html { redirect_to @start_finish, notice: 'Start finish was successfully updated.' }
        format.json { render :show, status: :ok, location: @start_finish }
      else
        format.html { render :edit }
        format.json { render json: @start_finish.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /start_finishes/1
  # DELETE /start_finishes/1.json
  def destroy
    @start_finish.destroy
    respond_to do |format|
      format.html { redirect_to start_finishes_url, notice: 'Start finish was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_start_finish
      @start_finish = StartFinish.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def start_finish_params
      params.require(:start_finish).permit(:point_number, :organizer_id, :start)
    end
end
