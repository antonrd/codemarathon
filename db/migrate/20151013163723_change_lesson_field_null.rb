class ChangeLessonFieldNull < ActiveRecord::Migration
  def change
    change_column_null(:lessons, :title, false)
    change_column_null(:lessons, :position, false)
    change_column_null(:lessons, :section_id, false)
  end
end
