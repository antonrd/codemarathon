class AddVisibleToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :visible, :boolean, null: false, default: false
  end
end
