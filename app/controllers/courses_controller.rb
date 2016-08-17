class CoursesController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show]
  before_action :require_teacher_role, except: [:index, :show]

  def index
    if user_signed_in?
      @admin_courses = current_user.classroom_records.admin.map { |record| record.classroom.course }.uniq
      @student_courses = current_user.classroom_records.student.map { |record| record.classroom.course }.uniq
      @other_courses = Course.visible_for(current_user) - @admin_courses - @student_courses
    else
      @admin_courses = @student_courses = []
      @other_courses = Course.all.visible
    end
  end

  def show
    course
    @wide_page = true
    unless course.visible || (user_signed_in? && current_user.is_teacher?)
      redirect_to root_path
    end
    store_location_for(:user, course_path(course))
  end

  def new
    @course = Course.new
  end

  def create
    @course = CreateCourse.new(course_params, current_user).call

    if @course.present?
      redirect_to course_path(@course), notice: "Course created successfully"
    else
      redirect_to new_course_path, alert: "Failed to create new course. #{ course.errors.full_messages }"
    end
  end

  def edit
    course
  end

  def update
    if course.update_attributes(course_params)
      redirect_to edit_course_path(course), notice: "Course updated successfully"
    else
      redirect_to edit_course_path(course), alert: "Failed to update course contents. #{ course.errors.full_messages }"
    end
  end

  def destroy
    course.destroy

    redirect_to root_path, notice: "Course was deleted successfully"
  end

  def edit_structure
    course
  end

  def set_main
    if course.present?
      main_course = Course.main.first
      if main_course != course
        main_course.update_attributes(is_main: false) if main_course.present?
        course.update_attributes(is_main: true)
      end
      redirect_to edit_course_path(course), notice: "New main course set"
    else
      redirect_to root_path, alert: "No matching course found"
    end
  end

  def unset_main
    if course.present?
      course.update_attributes(is_main: false)
      redirect_to edit_course_path(course), notice: "Course is not main anymore"
    else
      redirect_to root_path, alert: "No matching course found"
    end
  end

  protected

  def course
    @course ||= Course.find_by(slug: params[:id])
    raise ActiveRecord::RecordNotFound if @course.nil?
    @course
  end

  def course_params
    params.require(:course).permit(:title, :subtitle, :slug, :markdown_description, :markdown_long_description, :visible, :public)
  end
end
