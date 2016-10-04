module MenuHelper
  def lesson_menu_icon lesson
    if lesson.tasks.present?
      'tasks'
    elsif lesson.quizzes.present?
      'education'
    else
      'book'
    end
  end
end
