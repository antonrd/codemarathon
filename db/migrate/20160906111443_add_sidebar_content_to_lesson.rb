class AddSidebarContentToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :sidebar_content, :text
    add_column :lessons, :markdown_sidebar_content, :text
  end
end
