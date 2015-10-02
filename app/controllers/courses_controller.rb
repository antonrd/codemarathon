class CoursesController < ApplicationController
  def index
    @courses = Course.all
  end

  def show
    course
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.create(course_params)

    if @course
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

  protected

  def course
    @course ||= Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :markdown_description, :markdown_long_description)
  end
end
