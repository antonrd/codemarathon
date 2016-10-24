class UserInvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_role

  def index
    @user_invitations = UserInvitation.all
    @active_users_count = User.with_access.count
    @inactive_users_count = User.no_access.count
    @user_invitations_count = @user_invitations.count
  end

  def create
    user = User.find_by_email(user_invitation_params[:email].strip)

    user_invitation = UserInvitation.create!(email: user_invitation_params[:email].strip, used: false)

    message = "New user invitation created for #{ user_invitation_params[:email] }"
    if user.nil?
      UserInvitationsMailer.invitation_without_user(user_invitation).deliver_later
    elsif user.present? && !user.active
      UserInvitationsMailer.invitation_with_user(user_invitation).deliver_later
    else
      message += ". NOTE: User is already active, NO EMAIL SENT."
    end

    redirect_to user_invitations_path, notice: message
  end

  def update
    user_invitation = UserInvitation.find(params[:id])

    if user_invitation.update_attributes(email: user_invitation_params[:email].strip)
      redirect_to user_invitations_path, notice:
        "Invitation for #{ user_invitation.email } updated successfully"
    else
      redirect_to user_invitations_path, alert:
        "Failed to update invitation for #{ user_invitation.email }"
    end
  end

  def destroy
    user_invitation = UserInvitation.find(params[:id])
    if user_invitation.destroy
      redirect_to user_invitations_path, notice:
        "User invitation for #{ user_invitation.email } was deleted"
    else
      redirect_to user_invitations_path, alert:
        "Failed to delete invitation for #{ user_invitation.email }"
    end
  end

  private

  def user
    @user ||= User.find_by_email(params[:user_invitation][:email])
  end

  def user_invitation_params
    params.require(:user_invitation).permit(:email)
  end
end
