class AddCoupons < ActiveRecord::Migration
  def self.up

    create_table :coupons do |t|
      t.integer :subscription_id
      
      t.integer :promotional_plan_id, :null => false
      
      t.string :code, :length => 6
      
      # Timestamp for when the coupon is applied
      t.datetime :applied_on
      
      t.timestamps
    end
    
    add_index :coupons, :subscription_id
    add_index :coupons, :code, :unique => true
    
    # Add columns for keeping track of promotion status on subscriptions
    # When coupon is applied, update status of account to reflect coupon
    add_column :subscriptions, :permanently_free, :boolean, :null => false, :default => false
    add_column :subscriptions, :free_until, :datetime
    
    execute "UPDATE subscriptions SET permanently_free = false"
  end

  def self.down
    drop_table :coupons
    
    remove_column :subscriptions, :permanently_free
    remove_column :subscriptions, :free_until
  end
end
