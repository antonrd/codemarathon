class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.string :task_type, null: false
      t.text :markdown_description, null: false
      t.text :description, null: false
      t.integer :creator_id, null: false
      t.boolean :visible, null: false, default: false
      t.string :external_key
      t.integer :memory_limit_kb
      t.integer :time_limit_ms

      t.timestamps null: false
    end
  end
end
