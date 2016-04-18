class AddSlugToClassrooms < ActiveRecord::Migration
  def change
    add_column :classrooms, :slug, :string

    Classroom.all.each do |classroom|
      classroom.update_attributes(slug: classroom.course.slug)
    end

    change_column_null :classrooms, :slug, false

    add_index :classrooms, :slug, unique: true
  end
end
