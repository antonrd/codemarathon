class AddMainFlagToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :is_main, :boolean, null: false, default: false
  end
end
