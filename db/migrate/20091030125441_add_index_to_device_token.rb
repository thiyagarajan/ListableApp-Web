class AddIndexToDeviceToken < ActiveRecord::Migration
  def self.up
    add_index :users, :device_token
  end

  def self.down
    add_index :users, :device_token
  end
end
