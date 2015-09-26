class Users::PasswordsController < Devise::PasswordsController
  before_action :disallow_password_reset_for_oauth, only: [:create]

  protected

  def disallow_password_reset_for_oauth
    redirect_to root_path unless user.registered_with_email?
  end

  def user
    return User.find_by_email!(params[:user][:email])
  end
end
