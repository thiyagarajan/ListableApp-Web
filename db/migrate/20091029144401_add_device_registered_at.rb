class AddDeviceRegisteredAt < ActiveRecord::Migration
  def self.up
    add_column :users, :device_registered_at, :datetime
  end

  def self.down
    remove_column :users, :device_registered_at
  end
end
