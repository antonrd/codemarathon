class CreateClassroomRecords < ActiveRecord::Migration
  def change
    create_table :classroom_records do |t|
      t.integer :classroom_id, null: false
      t.integer :user_id, null: false
      t.string :role, null: false

      t.timestamps null: false
    end
  end
end
