class ClassroomsController < ApplicationController

  before_action :authenticate_user!, except: [:show, :lesson]
  before_action :check_enrolled_user, except: [:enroll, :add_waiting, :show, :lesson]
  before_action :is_viewable, only: [:show, :lesson]
  before_action :check_admin, except: [:show, :lesson, :lesson_task, :task_solution,
    :task_runs, :solve_task, :enroll, :progress, :add_waiting,
    :lesson_quiz, :attempt_quiz, :show_quiz_attempt, :submit_quiz]

  def show
    if current_user
      @lesson = classroom.course.first_visible_lesson(current_user)
      if @lesson.present?
        @lesson_record = @lesson.lesson_record_for(classroom, current_user)
        @lesson_record.add_view
        @prev_lesson = @lesson.previous_visible_lesson_in_course(admin_user: current_user.is_teacher?)
        @next_lesson = @lesson.next_visible_lesson_in_course(admin_user: current_user.is_teacher?)
      end
    else
      @lesson = classroom.course.sections.visible.ordered.first.lessons.visible.ordered.first
      @lesson_record = nil
      @prev_lesson = nil
      @next_lesson = @lesson.next_visible_lesson_in_course(admin_user: false)
    end

    # This will allow to control the open item of the menu
    gon.lesson_id = @lesson.id if @lesson.present?

    render 'lesson'
  end

  def lesson
    if load_lesson.present?
      if current_user
        @lesson_record.add_view
        @prev_lesson = @lesson.previous_visible_lesson_in_course(admin_user: current_user.is_teacher?)
        @next_lesson = @lesson.next_visible_lesson_in_course(admin_user: current_user.is_teacher?)
      else
        @prev_lesson = @lesson.previous_visible_lesson_in_course(admin_user: false)
        @next_lesson = @lesson.next_visible_lesson_in_course(admin_user: false)
      end

      store_location_for(:user, lesson_classroom_path(classroom, lesson_id: @lesson.id))
    else
      redirect_to root_path, alert: "Invalid lesson for classroom selected"
    end
  end

  def lesson_task
    if load_task.present?
      @user_runs_count = @task.user_runs(current_user).count
      @runs_limit = @task.task_record_for(current_user).runs_limit

      @task_run = nil
      if params[:task_run_id].present?
        @task_run = current_user.task_runs.find_by(id: params[:task_run_id], task: @task)
        flash[:alert] = "Invalid task run was specified" if @task_run.nil?
      end

      gon.cpp_boilerplate = @task.cpp_boilerplate
      gon.java_boilerplate = @task.java_boilerplate
      gon.python_boilerplate = @task.python_boilerplate
      gon.ruby_boilerplate = @task.ruby_boilerplate
      gon.with_unit_tests = @task.task_type == Task::TASK_TYPE_UNIT
      gon.last_programming_language = current_user.last_programming_language

      if @task_run
        gon.send("#{ @task_run.lang }_boilerplate=", @task_run.source_code)
        gon.last_programming_language = @task_run.lang
      end
    else
      redirect_to root_path, alert: "Invalid task for classroom selected"
    end
  end

  def lesson_quiz
    unless load_quiz.present?
      redirect_to root_path, alert: "Invalid quiz for classroom selected"
    end
  end

  def task_solution
    unless load_task.present?
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

  def attempt_quiz
    if load_quiz.present?
      allow_quiz_attempt
    else
      redirect_to root_path, alert: "Invalid quiz for classroom selected"
    end
  end

  def submit_quiz
    if load_quiz.present?
      return unless allow_quiz_attempt

      ScoreQuizAttempt.new(@quiz, current_user, params).call

      redirect_to lesson_quiz_classroom_path(@classroom, lesson_id: @lesson.id, quiz_id: @quiz.id),
        notice: "Quiz submitted successfully. Check your result below."
    else
      redirect_to root_path, alert: "Invalid quiz for classroom selected"
    end
  end

  def show_quiz_attempt
    if load_quiz.present?
      @quiz_attempt = @quiz.quiz_attempts.where(
        user: current_user, id: params[:quiz_attempt_id]).first

      if @quiz_attempt
        @attempt_answers = @quiz_attempt.deserialize_answers
      else
        raise ActiveRecord::RecordNotFound
      end
    else
      redirect_to root_path, alert: "Invalid quiz for classroom selected"
    end
  end

  def student_quiz_attempts
    if load_quiz.present?
      @user = User.find(params[:user_id])
      @quiz_attempts = @quiz.quiz_attempts.where(user: @user)
    else
      redirect_to root_path, alert: "Invalid quiz for classroom selected"
    end
  end

  def student_quiz_attempt
    if load_quiz.present?
      @user = User.find(params[:user_id])
      @quiz_attempt = @quiz.quiz_attempts.where(
        user: @user, id: params[:quiz_attempt_id]).first

      if @quiz_attempt
        @attempt_answers = @quiz_attempt.deserialize_answers
      else
        raise ActiveRecord::RecordNotFound
      end
    else
      redirect_to root_path, alert: "Invalid quiz for classroom selected"
    end
  end

  def enroll
    status = false
    Classroom.transaction do
      if classroom.spots_left > 0
        classroom.add_student(current_user)
        status = true
      end
    end

    if params[:last_lesson_id]
      next_path = lesson_classroom_path(classroom, params[:last_lesson_id])
    else
      next_path = classroom_path(classroom)
    end

    if status
      redirect_to next_path, notice: "User enrolled in classroom"
    else
      redirect_to next_path, alert: "It is not possible to enroll you at this time. Maybe the classroom has no free spots?"
    end
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

  def update_user_limit
    if params[:user_limit].present?
      classroom.update_user_limit(params[:user_limit].to_i)
    else
      classroom.update_user_limit(params[:user_limit])
    end

    redirect_to users_classroom_path(classroom), notice: "User limit for the classroom was updated"
  end

  def add_waiting
    classroom.add_student(current_user, false)

    redirect_to course_path(classroom.course), notice: "You are now on the waiting list for the course"
  end

  def activate_user
    user = User.find(params[:user_id])
    classroom.activate_user(user)

    redirect_to users_classroom_path(classroom), notice: "User #{ user.display_name } has been activated"
  end

  protected

  def classroom
    @classroom ||= Classroom.find_by(slug: params[:id])
    raise ActiveRecord::RecordNotFound if @classroom.nil?
    @classroom
  end

  def load_lesson
    @lesson ||= classroom.find_lesson(params[:lesson_id])
    if current_user
      @lesson_record = @lesson.lesson_record_for(classroom, current_user) if @lesson.present?
    else
      @lesson_record = nil
    end

    # This will allow to control the open item of the menu
    gon.lesson_id = @lesson.id

    @lesson
  end

  def load_task
    return unless load_lesson
    @task ||= classroom.find_task(params[:task_id], params[:lesson_id])
  end

  def load_quiz
    return unless load_lesson
    @quiz ||= classroom.find_quiz(params[:quiz_id], params[:lesson_id])
  end

  def check_enrolled_user
    redirect_to root_path, notice: "You need to be enrolled to access this page" unless classroom.has_access?(current_user)
  end

  def is_viewable
    unless classroom.course.public?
      authenticate_user!
      check_enrolled_user
    end
  end

  def check_admin
    redirect_to root_path unless classroom.is_admin?(current_user)
  end

  def allow_quiz_attempt
    if @quiz.attempts_depleted?(current_user)
      redirect_to lesson_quiz_classroom_path(@classroom, lesson_id: @lesson.id, quiz_id: @quiz.id),
        alert: "No more quiz attempts left."
      return false
    elsif @quiz.last_attempt_too_soon?(current_user)
      redirect_to lesson_quiz_classroom_path(@classroom, lesson_id: @lesson.id, quiz_id: @quiz.id),
        alert: "Your last attempt was too soon."
      return false
    end

    true
  end
end
