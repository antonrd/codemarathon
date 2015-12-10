class MakeTaskFieldsMandatory < ActiveRecord::Migration
  def change
    change_column_null(:tasks, :memory_limit_kb, false)
    change_column_null(:tasks, :time_limit_ms, false)
  end
end
