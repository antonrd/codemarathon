class ModifyCourseColumns < ActiveRecord::Migration
  def change
    change_column_null :courses, :title, false
    change_column_null :courses, :markdown_description, false
    change_column_null :courses, :description, false
    change_column_null :courses, :markdown_long_description, false
    change_column_null :courses, :long_description, false
  end
end
