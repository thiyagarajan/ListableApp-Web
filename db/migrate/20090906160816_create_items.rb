class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :list_id
      t.integer :creator_id

      t.boolean :completed, :null => false, :default => false
      
      t.string :name, :null => false, :limit => 1024
      
      t.timestamps
    end
    
    add_index :items, :list_id
    add_index :items, :completed
  end

  def self.down
    drop_table :items
  end
end
