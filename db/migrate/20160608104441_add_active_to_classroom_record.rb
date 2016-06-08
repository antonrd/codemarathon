class AddActiveToClassroomRecord < ActiveRecord::Migration
  def change
    add_column :classroom_records, :active, :boolean

    ClassroomRecord.find_each do |record|
      record.update_attributes(active: true)
    end

    change_column_null(:classroom_records, :active, false)
  end
end
