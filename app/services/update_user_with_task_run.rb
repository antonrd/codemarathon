class UpdateUserWithTaskRun
  def initialize run
    @run = run
  end

  def call
    update_lesson_records if update_task_record
  end

  protected

  attr_reader :run

  def update_task_record
    return false unless task_record.present?

    covered = false
    if run.points > task_record.best_score
      puts "Updating task #{ task.id } for run #{ run.id } with #{ run.points } points ..."
      covered = task_record.covered || run.points == Task::TASK_MAX_POINTS

      task_record.update_attributes(
        best_score: run.points,
        best_run_id: run.id,
        covered: covered
      )
    end

    covered
  end

  def task
    @task ||= run.task
  end

  def task_record
    @task_record ||= TaskRecord.find_or_create_by(user: user, task: task)
  end

  def user
    @user ||= run.user
  end

  def update_lesson_records
    task.lessons.each do |lesson|
      lesson.cover_lesson_records_if_lesson_covered(user)
    end
  end
end
