class AddSolutionToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :markdown_solution, :text
    add_column :tasks, :solution, :text
  end
end
