class LessonsController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def show
    lesson
  end

  def create
    section = Section.find(lesson_params[:section_id])

    if Lesson.create!(lesson_params.merge(position: section.last_lesson_position + 1))
      redirect_to edit_structure_course_path(section.course), notice: "Lesson created successfully"
    else
      redirect_to edit_structure_course_path(section.course), alert: "Failed to create new lesson"
    end
  end

  def edit
    lesson
  end

  def update
    if lesson.update_attributes(lesson_params)
      redirect_to edit_structure_course_path(course), notice: "Course updated successfully"
    else
      redirect_to edit_structure_course_path(course), alert: "Failed to update course contents"
    end
  end

  def destroy
    lesson.destroy

    redirect_to edit_structure_course_path(course), notice: "Lesson deleted"
  end

  def move_up
    lesson.move_up

    redirect_to edit_structure_course_path(course)
  end

  def move_down
    lesson.move_down

    redirect_to edit_structure_course_path(course)
  end

  protected

  def lesson
    @lesson ||= Lesson.find(params[:id])
  end

  def course
    lesson.section.course
  end

  def lesson_params
    params.require(:lesson).permit(:title, :section_id, :markdown_content)
  end
end
