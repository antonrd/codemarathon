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

  def lesson_task
    redirect_to root_path, alert: "Invalid task for classroom selected" unless load_task.present?
  end

  def task_runs
    if load_task.present?
      @user_runs = @task.user_runs(current_user)
    else
      redirect_to root_path, alert: "Invalid task for classroom selected"
    end
  end

  def solve_task
    load_task
    result = SolveTask.new(@task, current_user, params).call

    puts result

    if result.status
      redirect_to task_runs_classroom_path(@classroom, lesson_id: @lesson.id, task_id: @task.id), notice: result.message
    else
      redirect_to lesson_task_classroom_path(@classroom, lesson_id: @lesson.id, task_id: @task.id), alert: result.message
    end
  end

  def enroll
    classroom.add_student(current_user)

    redirect_to classroom_path(classroom), notice: "User enrolled in classroom"
  end

  def users
    classroom
  end

  def progress
    classroom
  end

  protected

  def classroom
    @classroom ||= Classroom.find(params[:id])
  end

  def load_lesson
    @lesson ||= classroom.find_lesson(params[:lesson_id])
  end

  def load_task
    return unless load_lesson
    @task ||= classroom.find_task(params[:task_id], params[:lesson_id])
  end

  def check_enrolled_user
    redirect_to root_path unless classroom.has_access?(current_user)
  end

  def check_admin
    redirect_to root_path unless classroom.is_admin?(current_user)
  end
end
