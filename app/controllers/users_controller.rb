class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :find_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @pagy, @users = pagy(User.all, items: Settings.pagy.items)
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      reset_session
      log_in @user
      flash[:success] = "Welcome to the sample app!"
      redirect_to @user
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = "Cap nhat thanh cong"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = "User deleted"
    else
      flash[:danger] = "Delete fail!"
    end
    redirect_to users_path
  end

  private
  def user_params
    params.require(:user).permit :name,
                                 :email,
                                 :password,
                                 :password_confirmation
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = "User not found!"
    redirect_to root_url
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = "Please log in."
    redirect_to login_url
  end

  def correct_user
    return if current_user? @user

    flash[:error] = "You cannot edit this account."
    redirect_to root_url
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
