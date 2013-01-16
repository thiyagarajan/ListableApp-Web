class RemoveSaas < ActiveRecord::Migration
  def self.up
    drop_table :coupons
    drop_table :subscriptions
    drop_table :subscription_transactions
    
    remove_column :users, :customer_vault_id
  end

  def self.down
    # Nope, gonna have to write these later if we need to go back.
  end
end
