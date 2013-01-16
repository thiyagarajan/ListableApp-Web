class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string    :email,               :null => false                # optional, you can use login instead, or both
      
      t.string    :first_name
      t.string    :last_name
      
      # Fields for cases where this user is created so that the user
      # may be invited to a list.  Record the creating user id and the 
      # list for which they were invited.
      t.integer   :creator_id
      t.integer   :originating_list_id
      
      t.string    :crypted_password,    :null => false                # optional, see below
      t.string    :password_salt,       :null => false                # optional, but highly recommended
      t.string    :persistence_token,   :null => false                # required
      t.string    :single_access_token, :null => false                # optional, see Authlogic::Session::Params
      t.string    :perishable_token,    :null => false                # optional, see Authlogic::Session::Perishability

      # Magic columns, just like ActiveRecord's created_at and updated_at. These are automatically maintained by Authlogic if they are present.
      t.integer   :login_count,         :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
      t.integer   :failed_login_count,  :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
      t.datetime  :last_request_at                                    # optional, see Authlogic::Session::MagicColumns
      t.datetime  :current_login_at                                   # optional, see Authlogic::Session::MagicColumns
      t.datetime  :last_login_at                                      # optional, see Authlogic::Session::MagicColumns
      t.string    :current_login_ip                                   # optional, see Authlogic::Session::MagicColumns
      t.string    :last_login_ip                                      # optional, see Authlogic::Session::MagicColumns

      # This is always true in normal running conditions, but if we need to deactivate an account on the fly
      # we can just toggle this field.
      t.boolean   :active, :default => true, :null => false

      # User must be activated with an email confirmation before logging in.
      t.boolean   :confirmed, :default => false, :null => false

      t.timestamps
    end
    
    add_index :users, :email, :unique => true
    add_index :users, :single_access_token, :unique => true
    add_index :users, :perishable_token, :unique => true
  end

  def self.down
    drop_table :users
  end
end
