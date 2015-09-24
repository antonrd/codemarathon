class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_authentication("Google", "devise.google_data")
  end

  def github
    handle_authentication("GitHub", "devise.github_data")
  end

protected

  def handle_authentication(kind, session_key)
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => kind
      sign_in_and_redirect @user, :event => :authentication
    else
      session[session_key] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end
end
