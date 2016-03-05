class AddUniqueConstraintOnClassroomRecords < ActiveRecord::Migration
  def change
    add_index :classroom_records, [:classroom_id, :user_id], unique: true
  end
end
