class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy
  before_action :load_user, except: %i(index new create)

  def index
    @users = User.page(params[:page]).per Settings.paging
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      flash[:danger] = "Please try again!"
      render :new
    end
  end

  def update
    if @user.update_attributes user_params
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render :edit
      flash[:danger] = "Profile update unsuccessful"
    end
  end

  def destroy
    User.find_by(id: params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find_by id: params[:id]
    return if current_user?@user
    
    flash[:danger] = "Unauthorized entry"
    redirect_to root_url
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  private
  def user_params
    params.require(:user).permit :name, :email, :password, :password_confirmation
  end
end
