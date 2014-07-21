class AddDataFieldsToUsers < ActiveRecord::Migration
  def self.up
  	add_column :users, :initials, :string
    add_column :users, :phone_number, :string
  end

  def self.down
  	remove_column :users, :initials, :string
    remove_column :users, :phone_number, :string
  end
end
