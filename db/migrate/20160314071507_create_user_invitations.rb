class CreateUserInvitations < ActiveRecord::Migration
  def change
    create_table :user_invitations do |t|
      t.string :email, null: false
      t.boolean :used, null: false, default: false
      t.datetime :used_at

      t.timestamps null: false
    end

    add_index :user_invitations, :email, unique: true
  end
end
