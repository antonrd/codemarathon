class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :title
      t.text :markdown_description
      t.text :description

      t.timestamps null: false
    end
  end
end
