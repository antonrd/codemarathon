class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.integer :course_id
      t.string :title
      t.integer :position

      t.timestamps null: false
    end
  end
end
