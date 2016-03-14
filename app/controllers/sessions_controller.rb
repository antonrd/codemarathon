class SessionsController < Devise::SessionsController
  before_action :check_if_active_user, only: :create

  private

  def check_if_active_user
    user = User.find_by(email: params[:user][:email])

    user.set_active_field if user

    # if user && !user.active
    #   user_invitation = UserInvitation.find_by(email: user.email)
    #   if user_invitation && !user_invitation.used?
    #     User.transaction do
    #       user.update_attributes(active: true)
    #       user_invitation.update_attributes(used: true, used_at: Time.now)
    #     end
    #   end
    # end

    if user && !user.active
      redirect_to new_user_session_path,
        alert: "This is a limited private beta site yet. "\
        "Your user is not activated at the moment. "\
        "We will notify you once we open access to your account."
    end
  end
end
