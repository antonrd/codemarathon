class SectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_teacher_role

  def create
    course = Course.find(section_params[:course_id])

    if Section.create!(section_params.merge(position: course.last_section_position + 1))
      redirect_to edit_structure_course_path(course), notice: "Section created successfully"
    else
      redirect_to edit_structure_course_path(course), alert: "Failed to create new section"
    end
  end

  def update
    if section.update_attributes(section_params)
      redirect_to edit_structure_course_path(course), notice: "Course updated successfully"
    else
      redirect_to edit_structure_course_path(course), alert: "Failed to update course contents"
    end
  end

  def destroy
    section.destroy

    redirect_to edit_structure_course_path(course), notice: "Section deleted"
  end

  def move_up
    section.move_up

    redirect_to edit_structure_course_path(course)
  end

  def move_down
    section.move_down

    redirect_to edit_structure_course_path(course)
  end

  protected

  def section
    @section ||= Section.find(params[:id])
  end

  def course
    section.course
  end

  def section_params
    params.require(:section).permit(:title, :course_id, :visible)
  end
end
