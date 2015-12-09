class CreateLessonRecords < ActiveRecord::Migration
  def change
    create_table :lesson_records do |t|
      t.integer :lesson_id, null: false
      t.integer :user_id, null: false
      t.integer :classroom_id, null: false
      t.integer :views, default: 0, null: false
      t.boolean :covered, default: false, null: false

      t.timestamps null: false
    end
  end
end
