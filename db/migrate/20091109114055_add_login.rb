class AddLogin < ActiveRecord::Migration
  def self.up
    add_column :users, :login, :string, :null => false
    
    # Make usernames for each user by first part of email
    User.all.each do |u|
      u.email =~ /(.*)?\@/
      u.update_attributes(:login => $1)
    end
    
    add_index :users, :login, :unique => true
  end

  def self.down
    remove_column :users, :login
  end
end
