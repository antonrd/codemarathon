class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.string :title
      t.integer :position
      t.integer :section_id

      t.timestamps null: false
    end
  end
end
