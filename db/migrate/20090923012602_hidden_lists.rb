class HiddenLists < ActiveRecord::Migration
  def self.up
    add_column :lists, :hidden, :boolean, :null => false, :default => false
    
    execute("UPDATE lists SET hidden = false")
    
    add_index :lists, :hidden
  end

  def self.down
    remove_column :lists, :hidden
  end
end
