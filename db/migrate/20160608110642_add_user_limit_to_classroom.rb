class AddUserLimitToClassroom < ActiveRecord::Migration
  def change
    add_column :classrooms, :user_limit, :integer
  end
end
