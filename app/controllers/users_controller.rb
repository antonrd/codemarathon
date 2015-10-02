class UsersController < ApplicationController
  before_action :require_admin_role

  def index
    @users = User.all
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
      redirect_to users_path, notice: "Role #{params[:role_type]} added to user #{@user.email}"
    end
  end

  def remove_user_role
    @user = User.find(params[:id])

    if @user.blank?
      redirect_to users_path, alert: "Invalid user" if @user.blank?
    else
      @user.remove_role(params[:role_type])
      redirect_to users_path, notice: "Role #{params[:role_type]} removed from user #{@user.email}"
    end
  end
end
