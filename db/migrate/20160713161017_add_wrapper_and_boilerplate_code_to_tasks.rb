class AddWrapperAndBoilerplateCodeToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :cpp_boilerplate, :text
    add_column :tasks, :cpp_wrapper, :text
    add_column :tasks, :java_boilerplate, :text
    add_column :tasks, :java_wrapper, :text
    add_column :tasks, :python_boilerplate, :text
    add_column :tasks, :python_wrapper, :text
    add_column :tasks, :ruby_boilerplate, :text
    add_column :tasks, :ruby_wrapper, :text
  end
end
