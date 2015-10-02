class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.integer :user_id, null: false
      t.string :role_type, null: false

      t.timestamps null: false
    end
  end
end
