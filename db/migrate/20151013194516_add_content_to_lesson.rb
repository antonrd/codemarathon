class AddContentToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :content, :text
    add_column :lessons, :markdown_content, :text
  end
end
