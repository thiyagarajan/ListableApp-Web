class AddDataFieldsToItems < ActiveRecord::Migration
  def self.up
  	add_column :items, :summary, :text
  	add_column :items, :details, :text
  	add_column :items, :attached_files, :string
  	add_column :items, :assigned_to_user_id, :integer
  	add_column :items, :target_date, :date
  	add_column :items, :completed_date, :date
  	add_column :items, :category, :string
  	add_column :items, :priority, :string
  	add_column :items, :last_updated, :date
  	add_column :items, :last_updated_by, :integer
  end

  def self.down
  	remove_column :items, :summary, :text
  	remove_column :items, :details, :text
  	remove_column :items, :attached_files, :string
  	remove_column :items, :assigned_to_user_id, :integer
  	remove_column :items, :target_date, :date
  	remove_column :items, :completed_date, :date
  	remove_column :items, :category, :string
  	remove_column :items, :priority, :string
  	remove_column :items, :last_updated, :date
  	remove_column :items, :last_updated_by, :integer
  end
end
