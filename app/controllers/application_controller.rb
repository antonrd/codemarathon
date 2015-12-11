class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(:user) || root_path
  end

  def require_admin_role
    require_role(User::ROLE_ADMIN)
  end

  def require_teacher_role
    require_role(User::ROLE_TEACHER)
  end

  def require_role role_type
    redirect_to root_path, alert: "Invalid page" unless current_user.present? && current_user.has_role?(role_type)
  end
end
