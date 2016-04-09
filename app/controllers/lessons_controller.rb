class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_teacher_role

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
      flash[:notice] = "Course updated successfully"
      render 'edit'
    else
      flash[:alert] = "Failed to update course contents"
      render 'edit'
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

  def attach_task
    if lesson.tasks.map(&:id).include?(params[:task_id])
      redirect_to edit_lesson_path(lesson), alert: "Task already attached to lesson"
    else
      lesson.tasks << Task.find(params[:task_id])
      redirect_to edit_lesson_path(lesson), notice: "Task attached to lesson successfully"
    end
  end

  def detach_task
    lesson.tasks.delete(Task.find(params[:task_id]))
    redirect_to edit_lesson_path(lesson), notice: "Task detached from lesson successfully"
  end

  protected

  def lesson
    @lesson ||= Lesson.find(params[:id])
  end

  def course
    lesson.section.course
  end

  def lesson_params
    params.require(:lesson).permit(:title, :section_id, :markdown_content, :visible)
  end
end
