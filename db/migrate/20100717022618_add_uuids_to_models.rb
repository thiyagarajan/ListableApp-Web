class AddUuidsToModels < ActiveRecord::Migration
  class List < ActiveRecord::Base ; end
  class Item < ActiveRecord::Base ; end
  
  def self.up
    add_column :items, :uuid, :string, :length => 36, :null => false
    add_column :lists, :uuid, :string, :length => 36, :null => false

    [ List, Item ].each do |klass|
      klass.find_each do |obj|
        obj.update_attributes(:uuid => Listable::Uuid.generate)
      end
    end

    add_index :items, :uuid, :unique => true
    add_index :lists, :uuid, :unique => true
  end

  def self.down
    remove_column :items, :uuid
    remove_column :lists, :uuid
  end
end
