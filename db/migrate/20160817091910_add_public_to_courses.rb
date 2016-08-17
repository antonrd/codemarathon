class AddPublicToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :public, :boolean, null: false, default: false
  end
end
