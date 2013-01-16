class CreateBlips < ActiveRecord::Migration
  def self.up
    create_table :blips do |t|
      t.integer :list_id
      
      t.integer :action_type_id
      
      t.integer :originating_user_id
      t.integer :destination_user_id

      t.string :modified_item_type
      t.integer :modified_item_id
      
      t.timestamps
    end
    
    add_index :blips, :list_id
    add_index :blips, :originating_user_id
    add_index :blips, :destination_user_id
    
    add_index :blips, :modified_item_type
    add_index :blips, :modified_item_id
  end

  def self.down
    drop_table :blips
  end
end
