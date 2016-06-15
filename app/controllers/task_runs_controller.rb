class TaskRunsController < ApplicationController
  before_action :authenticate_user!

  def show
    @task_run = TaskRun.find(params[:id])

    respond_to do |format|
      if @task_run.user == current_user
        format.js {}
      else
        format.json { render status: :unprocessable_entity }
      end
    end
  end
end
