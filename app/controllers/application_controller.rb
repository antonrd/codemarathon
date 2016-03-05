class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

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
    unless current_user.present? && current_user.has_role?(role_type)
      redirect_to root_path, alert: "Invalid page"
    end
  end

  def record_invalid(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def record_not_found(exception)
    head :not_found
  end
end
