class AddUpdateCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :update_count, :integer, :default => 0
    
    execute "UPDATE users set update_count = 0"
  end

  def self.down
    remove_column :users, :update_count
  end
end
