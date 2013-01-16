class CreateUserListLinks < ActiveRecord::Migration
  def self.up
    create_table :user_list_links do |t|
      t.integer :user_id, :null => false
      t.integer :list_id, :null => false
      
      # Used if this is an invitation, record the creating users' ID.
      t.integer :creator_id

      t.timestamps
    end
    
    add_index :user_list_links, :user_id
    add_index :user_list_links, :list_id
    
    # Don't make multiple links between a user and a list, that would just 
    # be annoying.
    add_index :user_list_links, [:user_id, :list_id], :unique => true
  end

  def self.down
    drop_table :user_list_links
  end
end
