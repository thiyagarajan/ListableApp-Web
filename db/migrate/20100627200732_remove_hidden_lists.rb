class RemoveHiddenLists < ActiveRecord::Migration
  def self.up
    List.all(:conditions => {:hidden => true}).each do |hidden_list|
      puts "Destroying links on a hidden list id #{hidden_list.id}."
      hidden_list.user_list_links.delete_all
    end

    remove_column :lists, :hidden
  end

  def self.down
    add_column :lists, :hidden, :boolean, :null => false, :default => false
    execute("UPDATE lists SET hidden = false")
    add_index :lists, :hidden    
  end
end
