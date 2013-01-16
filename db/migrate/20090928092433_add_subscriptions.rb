class AddSubscriptions < ActiveRecord::Migration
  def self.up
    create_table "subscriptions", :force => true do |t|
      t.integer  "plan_id", :null => false
      t.string   "state"
      t.integer "user_id"
      
      t.date     "next_renewal_on"
      t.integer  "warning_level"
      
      t.datetime "last_renewal_attempt"
      t.integer "renewal_attempts", :null => false, :default => 0
      
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    # Created when a client goes to purchase a subscription, and contains
    # follow response from the BrainTree server.  May not include the follow-
    # up information if a response is never received.
    create_table "subscription_transactions", :force => true do |t|
      t.integer  "subscription_id"
      
      t.integer  "plan_id"
      t.float  "amount"
      
      t.string   "key"
      t.string   "response"
      t.string   "responsetext"
      t.string   "authcode"
      t.string   "transactionid"
      t.string   "avsresponse"
      t.string   "time"
      t.string   "customer_vault_id"
      t.string   "cvvresponse"
      t.string   "response_code"

      t.string   "customer_ip"
      t.string   "response_hash"
      
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    add_column :users, :customer_vault_id, :integer
    add_index :subscriptions, :user_id
    add_index :subscription_transactions, :subscription_id
  end

  def self.down
    drop_table :subscriptions
    drop_table :subscription_transactions
    
    remove_column :users, :customer_vault_id
  end
end
