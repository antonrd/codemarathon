class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_role, except: [:edit_profile, :update_profile, :set_last_programming_language]

  def index
    @users = User.active
    @inactive_users_count = User.inactive.count
    @user_invitations_count = UserInvitation.count
  end

  def inactive
    @inactive_users = User.inactive
  end

  def show
    @user = User.find(params[:id])

    redirect_to users_path, alert: "Invalid user" if @user.blank?
  end

  def add_user_role
    @user = User.find(params[:id])

    if @user.blank?
      redirect_to users_path, alert: "Invalid user" if @user.blank?
    else
      @user.add_role(params[:role_type])
      redirect_to user_path(@user), notice: "Role #{params[:role_type]} added to user #{@user.email}"
    end
  end

  def remove_user_role
    @user = User.find(params[:id])

    if @user.blank?
      redirect_to users_path, alert: "Invalid user" if @user.blank?
    else
      @user.remove_role(params[:role_type])
      redirect_to user_path(@user), notice: "Role #{params[:role_type]} removed from user #{@user.email}"
    end
  end

  def edit_profile
    @user = current_user
  end

  def update_profile
    if current_user.update_attributes(user_profile_params)
      redirect_to edit_profile_path, notice: "Profile updated successfully"
    else
      redirect_to edit_profile_path, alert: "Failed to update user profile"
    end
  end

  protected

  def user_profile_params
    params.require(:user).permit(:name)
  end
end
