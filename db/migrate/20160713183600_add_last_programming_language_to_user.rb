class AddLastProgrammingLanguageToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_programming_language, :string
  end
end
