class UserInvitationsMailer < ActionMailer::Base
  default from: 'HiredInTech <team@hiredintech.com>'

  def invitation_without_user(user_invitation)
    mail(to: user_invitation.email, subject: "Your invitation to HiredInTech's Interview Training Camp")
  end

  def invitation_with_user(user_invitation)
    mail(to: user_invitation.email, subject: "Your invitation to HiredInTech's Interview Training Camp")
  end
end
