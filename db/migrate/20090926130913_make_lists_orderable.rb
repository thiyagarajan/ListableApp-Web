class MakeListsOrderable < ActiveRecord::Migration
  def self.up
    add_column :user_list_links, :position, :integer
    add_index :user_list_links, :position
  end

  def self.down
    remove_column :user_list_links, :position
  end
end
