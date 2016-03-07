class ConfirmationsController < Devise::ConfirmationsController
  before_action :check_user_not_signed_in

  def show
    matching_user = User.confirm_by_token(params[:confirmation_token])

    if matching_user.errors.empty?
      redirect_to new_user_session_path, notice: "Account confirmed successfully! Try to log in."
    else
      message = matching_user.errors.full_messages.join(". ")
      redirect_to new_user_session_path, alert: message
    end
  end

  def create
    user = User.find_by_email(params[:user][:email])
    user.send_confirmation_instructions if user

    redirect_to new_user_session_path, notice: "Confirmation instructions sent."
  end

  protected

  def check_user_not_signed_in
    redirect_to root_path, alert: "You are already signed in" if user_signed_in?
  end
end
