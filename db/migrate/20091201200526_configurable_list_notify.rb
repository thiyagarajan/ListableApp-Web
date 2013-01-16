class ConfigurableListNotify < ActiveRecord::Migration
  def self.up
    add_column :user_list_links, :watching, :boolean, :null => false, :default => true
    add_index :user_list_links, :watching
    
    execute("UPDATE user_list_links SET watching = true")
  end

  def self.down
    remove_column :user_list_links, :watching
  end
end
