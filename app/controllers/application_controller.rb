class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def require_admin_role
    redirect_to root_path, alert: "Invalid page" unless current_user.has_role?(User::ROLE_ADMIN)
  end
end
