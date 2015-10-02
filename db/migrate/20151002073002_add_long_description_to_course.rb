class AddLongDescriptionToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :markdown_long_description, :text
    add_column :courses, :long_description, :text
  end
end
