class RegistrationsController < Devise::RegistrationsController

  before_action :disallow_password_change_with_oauth, only: [:edit, :update]

  protected

  def disallow_password_change_with_oauth
    redirect_to root_path unless current_user.registered_with_email?
  end

end
