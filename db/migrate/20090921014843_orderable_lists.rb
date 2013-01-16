class OrderableLists < ActiveRecord::Migration
  def self.up
    add_column :items, :position, :integer
    add_index :items, :position
  end

  def self.down
    remove_column :items, :position
  end
end
