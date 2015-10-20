class MakeClassroomFieldsNonNull < ActiveRecord::Migration
  def change
    change_column_null(:classrooms, :name, false)
    change_column_null(:classrooms, :course_id, false)
  end
end
