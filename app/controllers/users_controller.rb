class UsersController < ApplicationController
  before_action :find_user, only: :show

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      reset_session
      log_in @user
      flash[:success] = "User created successful"
      redirect_to @user
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user)
          .permit :name, :email, :password, :password_confirmation
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = "User not found!"
    redirect_to root_url
  end
end
