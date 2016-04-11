class ClassroomsController < ApplicationController

  before_action :authenticate_user!
  before_action :check_enrolled_user, except: [:enroll]
  before_action :check_admin, only: [:users, :student_progress, :student_task_runs, :remove_user]

  def show
    @lesson = classroom.course.first_visible_lesson(current_user)
    if @lesson.present?
      @lesson_record = @lesson.lesson_record_for(classroom, current_user)
      @lesson_record.add_view
    end

    render 'lesson'
  end

  def lesson
    if load_lesson.present?
      @lesson_record.add_view
    else
      redirect_to root_path, alert: "Invalid lesson for classroom selected"
    end
  end

  def lesson_task
    if load_task.present?
      @user_runs_count = @task.user_runs(current_user).count
      @runs_limit = @task.task_record_for(current_user).runs_limit
    else
      redirect_to root_path, alert: "Invalid task for classroom selected"
    end
  end

  def task_runs
    if load_task.present?
      @user_runs = @task.user_runs(current_user).page(params[:page]).per(20)
    else
      redirect_to root_path, alert: "Invalid task for classroom selected"
    end
  end

  def student_task_runs
    if load_task.present?
      @user = User.find(params[:user_id])
      @user_runs = @task.user_runs(@user).page(params[:page]).per(20)
    else
      redirect_to root_path, alert: "Invalid task for classroom selected"
    end
  end

  def solve_task
    load_task

    if @task.attempts_depleted?(current_user)
      redirect_to lesson_task_classroom_path(@classroom, lesson_id: @lesson.id,
        task_id: @task.id), alert: "No task solving attempts left."
      return
    end

    result = SolveTask.new(@task, current_user, params).call

    if result.status
      redirect_to task_runs_classroom_path(@classroom, lesson_id: @lesson.id,
        task_id: @task.id), notice: result.message
    else
      redirect_to lesson_task_classroom_path(@classroom, lesson_id: @lesson.id,
        task_id: @task.id), alert: result.message
    end
  end

  def enroll
    classroom.add_student(current_user)

    redirect_to classroom_path(classroom), notice: "User enrolled in classroom"
  end

  def remove_user
    user = User.find(params[:user_id])
    classroom.remove_user(user)

    redirect_to users_classroom_path(classroom), notice: "User #{ user.display_name } removed from classroom"
  end

  def users
    classroom
  end

  def progress
    classroom
    @user = current_user
  end

  def student_progress
    classroom
    @user = User.find(params[:user_id])
    render 'progress'
  end

  protected

  def classroom
    @classroom ||= Classroom.find(params[:id])
  end

  def load_lesson
    @lesson ||= classroom.find_lesson(params[:lesson_id])
    @lesson_record = @lesson.lesson_record_for(classroom, current_user) if @lesson.present?
    @lesson
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
