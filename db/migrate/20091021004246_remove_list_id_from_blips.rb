class RemoveListIdFromBlips < ActiveRecord::Migration
  def self.up
    remove_column :blips, :list_id
  end

  def self.down
    add_column :blips, :list_id, :integer
    add_index :blips, :list_id
  end
end
