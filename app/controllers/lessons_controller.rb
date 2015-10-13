class LessonsController < ApplicationController
  def update
    if lesson.update_attributes(lesson_params)
      redirect_to edit_structure_course_path(course), notice: "Course updated successfully"
    else
      redirect_to edit_structure_course_path(course), alert: "Failed to update course contents"
    end
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
    params.require(:lesson).permit(:title)
  end
end
