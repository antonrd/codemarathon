class PasswordsController < Devise::PasswordsController
  def create
    user = User.find_by_email(params[:user][:email])
    user.send_reset_password_instructions if user

    redirect_to new_user_session_path, notice: "Instructions for resetting your password were sent"
  end
end
