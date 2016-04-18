class AddSlugToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :slug, :string

    Course.all.each do |course|
      slug = course.title.downcase.gsub(/\s/, "-").gsub(/[^a-z0-9\-]/, "")[0..15]
      course.update_attributes(slug: slug)
    end

    change_column_null(:courses, :slug, false)
  end
end
