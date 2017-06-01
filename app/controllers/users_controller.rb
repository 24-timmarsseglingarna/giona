class UsersController < ApplicationController
  include ApplicationHelper
  before_action :set_user, only: [:show, :edit, :update, :destroy, :recover]
  before_action :authenticate_user!
  before_action :authorize_me!, only: [:show, :edit, :update]
  before_action :authorize_admin!, :except => [:show, :edit, :update]
  has_scope :from_person

  # GET /users
  # GET /users.json
  def index
    @users = apply_scopes(User).all
  end

  def inactive
    @users = User.only_deleted
    render action: :index
  end

  def recover
    @user.recover
    redirect_to @user, notice: 'Uppgifterna om användaren återskapades.'
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'Uppgifterna om användaren lades till.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'Uppgifterna om användaren uppdaterades.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'Uppgifterna om användaren raderades.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      #@user = User.find(params[:id])
      @user = User.with_deleted.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      if has_assistant_rights?
        params.require(:user).permit(:email, :role)
      else
        params.require(:user).permit(:email)
      end
        

    end

    def authorize_me!
      unless (@user.id == current_user.id) || has_assistant_rights?
        flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
        redirect_to :back
      end
    end

    def authorize_admin!
      unless has_assistant_rights?
        flash[:alert] = 'Du har tyvärr inte tillräckliga behörigheter.'
        redirect_to :back
      end
    end
end
