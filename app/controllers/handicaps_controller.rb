# coding: utf-8
class HandicapsController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_user!
  before_action :authorized?, :except => [:show, :index]

  IMPORT_TYPES = %w[SrsKeelboat SrsMultihull SrsCertificate SrsMultihullCertificate SxkCertificate].freeze

  before_action :set_handicap, only: [:show, :edit, :update, :destroy]
  before_action :set_type

  def import
  end

  def run_import
    type = params[:import_type]
    unless IMPORT_TYPES.include?(type)
      redirect_to import_handicaps_path, alert: "Okänd importtyp."
      return
    end
    user = User.find_by!(email: 'nobody@24-timmars.nu')
    HandicapImporter.public_send(type.underscore.pluralize, user)
    redirect_to import_handicaps_path, notice: "Import av #{type} klar."
  rescue => e
    redirect_to import_handicaps_path, alert: "Import misslyckades: #{e.message}"
  end

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
      params.require(@handicap.type.underscore.to_sym).permit(:name, :sxk, :expired_at, :source, :srs, :registry_id, :sail_number, :boat_name, :owner_name, :external_system, :external_id)
    end

    def authorized?
      if ! has_admin_rights?
        flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
        redirect_to :back
      end
    end

end
