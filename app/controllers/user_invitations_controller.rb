class UserInvitationsController < ApplicationController
  def index
    @user_invitations = UserInvitation.all
  end

  def create
    user_invitation = UserInvitation.create!(email: user_invitation_params[:email], used: false)
    redirect_to user_invitations_path, notice:
      "New user invitation created for #{ user_invitation_params[:email] }"
  end

  def update
    user_invitation = UserInvitation.find(params[:id])

    if user_invitation.update_attributes(email: user_invitation_params[:email])
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

  def user_invitation_params
    params.require(:user_invitation).permit(:email)
  end
end
