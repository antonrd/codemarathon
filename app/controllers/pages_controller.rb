class PagesController < ApplicationController
  def home
    course = Course.main.first
    if course.present?
      redirect_to course_path(course)
    else
      redirect_to courses_path
    end
  end
end
