class AddPromoEmailCheckbox < ActiveRecord::Migration
  def self.up
    add_column :users, :accept_promo_emails, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :users, :accept_promo_emails
  end
end
