class AddRolesTable < ActiveRecord::Migration
  def change
    create_table(:roles) do |t|
      t.integer :user_id, null: false
      t.string :role_name, null: false
    end
  end
end
