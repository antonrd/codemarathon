class MakeSectionFieldsNonNull < ActiveRecord::Migration
  def change
    change_column_null(:sections, :title, false)
    change_column_null(:sections, :position, false)
    change_column_null(:sections, :course_id, false)
  end
end
