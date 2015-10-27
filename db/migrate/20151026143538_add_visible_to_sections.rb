class AddVisibleToSections < ActiveRecord::Migration
  def change
    add_column :sections, :visible, :boolean, null: false, default: false
  end
end
