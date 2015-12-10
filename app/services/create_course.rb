class CreateCourse
  def initialize course_params, creating_user
    @course_params = course_params
    @creating_user = creating_user
  end

  def call
    course = nil
    Course.transaction do
      course = Course.create(course_params)
      classroom = course.classrooms.create(name: "Default classroom")
      return unless classroom.persisted?
      classroom.add_admin(creating_user)
    end

    course
  end

  protected

  attr_reader :course_params, :creating_user
end
