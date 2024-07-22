class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new create show)
  before_action :find_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @pagy, @users = pagy(User.sorted_by_created_at, items: Settings.pagy.items)
  end

  def show
    @page, @microposts = pagy(@user.microposts, items: Settings.pagy.items)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url, status: :see_other
    else
      flash[:error] = @user.errors.full_messages
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

  def following
    @title = "Following"
    @pagy, @users = pagy @user.following, items: Settings.pagy.items
    render :show_follow
  end

  def followers
    @title = "Followers"
    @pagy, @users = pagy @user.followers, items: Settings.pagy.items
    render :show_follow
  end

  private
  def user_params
    params.require(:user).permit(:name,
                                 :email,
                                 :password,
                                 :password_confirmation)
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

  # Confirms the correct user.
  def correct_user
    return if current_user? @user

    flash[:error] = "You cannot edit this account."
    redirect_to root_url
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
