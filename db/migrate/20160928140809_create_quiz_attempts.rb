class CreateQuizAttempts < ActiveRecord::Migration
  def change
    create_table :quiz_attempts do |t|
      t.integer :quiz_id, null: false
      t.integer :user_id, null: false
      t.float :score, null: false
      t.text :answers_json, null: false
      t.text :message

      t.timestamps null: false
    end
  end
end
