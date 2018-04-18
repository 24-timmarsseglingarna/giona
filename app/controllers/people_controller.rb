class PeopleController < ApplicationController
  include ApplicationHelper
  include PeopleHelper

  before_action :authenticate_user!
  before_action :authorize_assistant!, only: [:inactive, :recover, :destroy]
  before_action :set_person, only: [:show, :edit, :update, :destroy, :agreement, :consent]
  before_action :insert_token_headers

  acts_as_token_authentication_handler_for User

  has_scope :has_team, :has_user


  # GET /people
  # GET /people.json
  def index
    if has_assistant_rights?
      @people = apply_scopes(Person).all
    else
      @people = apply_scopes(Person).select("id, first_name, last_name, city, deleted_at")
    end
  end

  def inactive
    @people = Person.only_deleted
    render action: :index
  end

  def recover
    @person = Person.with_deleted.find(params[:id])
    @person.recover
    redirect_to @person, notice: 'Uppgifterna om personen återskapades.'
  end

  # GET /people/1
  # GET /people/1.json
  def show
    if ! authorized?
      @person = Person.select("id, first_name, last_name, city, country").with_deleted.find(params[:id])
      @teams = @person.teams.order active: :desc, created_at: :desc
    end
  end

  # GET /people/new
  def new
    @person = Person.new
    @agreement = Agreement.last
    @person.skip_validation = false
    if params[:add_me] == 'true' && current_user
      @person.email = current_user.email
    end
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(person_params)
    @agreement = Agreement.last
    @person.skip_validation = false
    respond_to do |format|
      if @person.save
        @person.agreements << Agreement.last
        if current_user
          if current_user.user?
            current_user.person_id = @person.id
            current_user.save
          end
        end
        format.html { redirect_to @person, notice: 'Uppgifterna lades till. Tack.' }
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    respond_to do |format|
      if @person.update(person_params)
        if current_user
          if current_user.user?
            current_user.person_id = @person.id
            current_user.save
          end
        end
        format.html { redirect_to @person, notice: 'Uppgifterna uppdaterades. Tack' }
        format.json { render :show, status: :ok, location: @person }
      else
        format.html { render :edit }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url, notice: 'Uppgifterna om personen raderades.' }
      format.json { head :no_content }
    end
  end

  def agreement
    @consents = @person.consents.reverse
    render 'agreement'
  end

  def consent
    if @person.agreements.include? Agreement.last
      redirect_to @person, notice: 'Du har redan godkänt användaravtalet.'
    else
      @person.agreements << Agreement.last
      flash.discard
      redirect_to @person, notice: 'Tack för att du godkände användaravtalet.'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      #@person = Person.find(params[:id])
      @person = Person.with_deleted.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def person_params
      params.require(:person).permit(:email, :first_name, :last_name, :co, :street, :zip, :city, :country, :birthday, :phone, :external_system, :external_id)
    end

    def authorize_assistant!
      if ! has_assistant_rights?
        flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
        redirect_to :back
      end
    end
end
