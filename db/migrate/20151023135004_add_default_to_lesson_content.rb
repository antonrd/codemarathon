class AddDefaultToLessonContent < ActiveRecord::Migration
  def change
    change_column_default(:lessons, :content, "")
    change_column_default(:lessons, :markdown_content, "")

    Lesson.where(content: nil).update_all(content: "")
    Lesson.where(markdown_content: nil).update_all(markdown_content: "")

    change_column_null(:lessons, :content, false)
    change_column_null(:lessons, :markdown_content, false)
  end
end
