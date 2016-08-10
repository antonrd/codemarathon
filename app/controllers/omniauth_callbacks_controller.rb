class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_authentication("Google", "devise.google_data")
  end

  def github
    handle_authentication("GitHub", "devise.github_data")
  end

  def facebook
    handle_authentication("Facebook", "devise.facebook_data")
  end

protected

  def handle_authentication(kind, session_key)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      if @user.active?
        sign_in_and_redirect @user, event: :authentication
      else
        redirect_to new_user_session_path,
          alert: "This is a limited private beta site yet. "\
          "Your user is not activated at the moment. "\
          "We will notify you once we open access to your account."
      end
    else
      session[session_key] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end
end
