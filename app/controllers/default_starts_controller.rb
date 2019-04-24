class DefaultStartsController < ApplicationController
  include ApplicationHelper

  before_action :set_default_start, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, :except => [:show, :index]
  before_action :authorized?, :except => [:show, :index]


  # GET /default_starts
  # GET /default_starts.json
  def index
    @default_starts = DefaultStart.all
  end

  # GET /default_starts/1
  # GET /default_starts/1.json
  def show
  end

  # GET /default_starts/new
  def new
    @default_start = DefaultStart.new
  end

  # GET /default_starts/1/edit
  def edit
  end

  # POST /default_starts
  # POST /default_starts.json
  def create
    @default_start = DefaultStart.new(default_start_params)

    respond_to do |format|
      if @default_start.save
        format.html { redirect_to @default_start, notice: 'Default start was successfully created.' }
        format.json { render :show, status: :created, location: @default_start }
      else
        format.html { render :new }
        format.json { render json: @default_start.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /default_starts/1
  # PATCH/PUT /default_starts/1.json
  def update
    respond_to do |format|
      if @default_start.update(default_start_params)
        format.html { redirect_to @default_start, notice: 'Default start was successfully updated.' }
        format.json { render :show, status: :ok, location: @default_start }
      else
        format.html { render :edit }
        format.json { render json: @default_start.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /default_starts/1
  # DELETE /default_starts/1.json
  def destroy
    @default_start.destroy
    respond_to do |format|
      format.html { redirect_to default_starts_url, notice: 'Default start was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_default_start
      @default_start = DefaultStart.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def default_start_params
      params.require(:default_start).permit(:organizer_id, :number)
    end

    def authorized?
      if ! has_officer_rights?
        flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
        redirect_to :back
      end
    end

end
