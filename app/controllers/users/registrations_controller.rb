class Users::RegistrationsController < Devise::RegistrationsController

  before_action :disallow_password_change_with_oauth, only: [:edit, :update]

  def edit_profile
    @user = current_user
  end

  def update_profile
    if current_user.update_attributes(user_profile_params)
      redirect_to edit_user_profile_path, notice: "Profile updated successfully"
    else
      redirect_to edit_user_profile_path, alert: "Failed to update user profile"
    end
  end

  protected

  def user_profile_params
    params.require(:user).permit(:name)
  end

  def account_update_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end

  def disallow_password_change_with_oauth
    redirect_to root_path unless current_user.registered_with_email?
  end

end
