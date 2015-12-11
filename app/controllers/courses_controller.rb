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
      @other_courses = Course.all
    end
  end

  def show
    course
    redirect_to root_path unless course.visible || current_user.is_teacher?
  end

  def new
    @course = Course.new
  end

  def create
    @course = CreateCourse.new(course_params, current_user).call

    if @course.present?
      redirect_to course_path(@course), notice: "Course created successfully"
    else
      redirect_to new_course_path, alert: "Failed to create new course"
    end
  end

  def edit
    course
  end

  def update
    if course.update_attributes(course_params)
      redirect_to edit_course_path(course), notice: "Course updated successfully"
    else
      redirect_to edit_course_path(course), alert: "Failed to update course contents"
    end
  end

  def destroy
    course.destroy

    redirect_to root_path, notice: "Course was deleted successfully"
  end

  def edit_structure
    course
  end

  protected

  def course
    @course ||= Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :markdown_description, :markdown_long_description, :visible)
  end
end
