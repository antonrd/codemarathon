class ClassroomsController < ApplicationController

  before_action :authenticate_user!
  before_action :check_enrolled_user, except: [:enroll]
  before_action :check_admin, only: [:users]

  def show
    @lesson = classroom.course.first_lesson
    render 'lesson'
  end

  def lesson
    redirect_to root_path, alert: "Invalid lesson for classroom selected" unless load_lesson.present?
  end

  def enroll
    classroom.add_student(current_user)

    redirect_to classroom_path(classroom), notice: "User enrolled in classroom"
  end

  def users
    classroom
  end

  protected

  def classroom
    @classroom ||= Classroom.find(params[:id])
  end

  def load_lesson
    @lesson ||= classroom.find_lesson(params[:lesson_id])
  end

  def check_enrolled_user
    redirect_to root_path unless classroom.has_access?(current_user)
  end

  def check_admin
    redirect_to root_path unless classroom.is_admin?(current_user)
  end
end
