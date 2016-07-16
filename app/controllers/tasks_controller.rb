class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_teacher_role

  def index
    @tasks = Task.all
  end

  def show
    task
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.create(task_params.merge(creator_id: current_user.id))

    if @task.present?
      api = GraderApi.new
      response = api.add_task(@task)

      if response["status"] == 0
        @task.update_attribute(:external_key, response["task_id"])
        redirect_to task_path(@task), notice: "New task '#{ @task.title } created."
      else
        flash[:alert] = "Failed to upload task data. Message: %s" % [response["message"]]
        render 'new'
      end
    else
      flash[:alert] = "Failed to create new task"
      render 'new'
    end
  end

  def edit
    task
  end

  def update
    if task.update_attributes(task_params)
      api = GraderApi.new

      if task.external_key.present?
        response = api.update_task(task)
      else
        response = api.add_task(task)
      end

      if response["status"] == 0
        task.update_attribute(:external_key, response["task_id"])
        redirect_to task_path(task), notice: "Task '#{ task.title } was updated."
      else
        flash[:alert] = "Failed to upload task data. Message: %s" % [response["message"]]
        render 'edit'
      end
    else
      flash[:alert] = "Failed to update task '#{ task.title }'. Error: #{ task.errors.full_messages }."
      render 'edit'
    end
  end

  def solution
    task
  end

  def update_checker
    result = SolveTask.new(task, current_user, params, TaskRun::TYPE_UPDATE_CHECKER).call

    if result.status
      redirect_to edit_task_path(task), notice: result.message
    else
      redirect_to edit_task_path(task), alert: result.message
    end
  end

  def destroy
    task.destroy

    redirect_to tasks_path, notice: "Task was deleted successfully"
  end

  def solve
    task
    @run = nil

    gon.cpp_boilerplate = @task.cpp_boilerplate
    gon.java_boilerplate = @task.java_boilerplate
    gon.python_boilerplate = @task.python_boilerplate
    gon.ruby_boilerplate = @task.ruby_boilerplate
  end

  def do_solve
    result = SolveTask.new(task, current_user, params).call

    if result.status
      redirect_to solve_task_path(task), notice: result.message
    else
      redirect_to solve_task_path(task), alert: result.message
    end
  end

  def resubmit_run
    task_run = task.task_runs.find_by(id: params[:task_run_id])
    if task_run && task_run.external_key.present?
      response = GraderApi.new.resubmit_run(task, task_run)
      if response["status"] == 0
        task_run.update_attributes(status: TaskRun::STATUS_PENDING,
          display_status: "Pending")
        redirect_to runs_task_path(task), notice: "Run #{ task_run.id } resubmitted"
      else
        redirect_to runs_task_path(task),
          alert: "There was a problem resubmitting run #{ task_run.id }. #{ response["message"] }"
      end
    else
      render :not_found
    end
  end

  def runs
    @task_runs = task.task_runs.newest_first.page(params[:page]).per(30)
  end

  def runs_limits
    @task_records = task.task_records
  end

  def update_runs_limit
    task.task_record_for(task_user).update_attributes(runs_limit: params[:new_runs_limit])
    redirect_to runs_limits_task_path(task),
      notice: "Task runs limit changed for user #{ task_user.display_name }"
  end

  def all_runs
    @task_runs = TaskRun.newest_first.page(params[:page]).per(100)
  end

  protected

  def task
    @task ||= Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :task_type, :markdown_description,
      :markdown_solution, :visible, :memory_limit_kb, :time_limit_ms,
      :cpp_boilerplate, :cpp_wrapper, :java_boilerplate, :java_wrapper,
      :python_boilerplate, :python_wrapper, :ruby_boilerplate, :ruby_wrapper)
  end

  def task_user
    @task_user ||= User.find(params[:user_id])
  end
end
