class ClassroomsController < ApplicationController

  before_action :authenticate_user!

  def show
    classroom
  end

  def enroll
    classroom.add_student(current_user)

    redirect_to classroom_path(classroom), notice: "User enrolled in classroom"
  end

  protected

  def classroom
    @classroom ||= Classroom.find(params[:id])
  end
end
