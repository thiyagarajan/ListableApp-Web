class DenormalizeBlips < ActiveRecord::Migration
  def self.up
    add_column :blips, :list_id, :integer
    
    add_index :blips, :list_id
    
    execute("delete from blips")
    
    add_column :blips, :affected_entity_name, :string, :limit => 1024
  end

  def self.down
    remove_column :blips, :list_id
    remove_column :blips, :affected_entity_name
  end
end
