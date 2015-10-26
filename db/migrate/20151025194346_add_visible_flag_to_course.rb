class AddVisibleFlagToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :visible, :boolean, null: false, default: false
  end
end
