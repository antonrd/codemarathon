class AddUniqueIndexOnCourseSlug < ActiveRecord::Migration
  def change
    add_index :courses, :slug, unique: true
  end
end
