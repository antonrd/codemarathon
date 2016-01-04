class MakeSourceCodeNullableInTask < ActiveRecord::Migration
  def change
    change_column_null(:task_runs, :source_code, true)
  end
end
