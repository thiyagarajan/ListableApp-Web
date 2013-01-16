require 'authlogic'

class User < ActiveRecord::Base
  
  acts_as_authentic do |c|
    # Don't change the perishable token on updates to this model.
    c.disable_perishable_token_maintenance = true
    c.validates_format_of_login_field_options( :with => /\A\w[\w\.+\@\-_]+\z/, :message => I18n.t('error_messages.login_invalid', :default => "should use only letters, numbers, and .-_@ please.") )
  end
  
  has_many :user_list_links, :order => :position, :dependent => :destroy
  has_many :lists, :through => :user_list_links, :order => "user_list_links.position ASC"

  has_many :blips_for_me, :class_name => 'Blip', :foreign_key => :originating_user_id
  has_many :blips_from_me, :class_name => 'Blip', :foreign_key => :destination_user_id
  
  belongs_to :creator, :class_name => 'User'
  has_one :originating_list, :class_name => 'List'
  
  has_many :created_lists, :class_name => 'List', :foreign_key => 'creator_id'

  # Since we turn off perishable session maintenance, we have to start with a default token here.
  before_create :reset_perishable_token

  # Sets the update_count to 0 and saves record if the update_count is not already 0
  def reset_update_count
    self.update_attributes(:update_count => 0) unless self.update_count == 0
  end

  def deliver_email_confirmation!
    reset_perishable_token!
    Notifier.deliver_email_confirmation(self)
  end
  
  def deliver_password_reset_instructions!  
    reset_perishable_token! 
    Notifier.deliver_password_reset_instructions(self)
  end  
    
  def device_token_hex
    [self.device_token.delete(' ')].pack('H*')
  end
  
  # Allow users to log in both by their login or by username, since many 
  # seem to be confused by the distinction.  Relies on a line in user_session.rb
  # as well.
  def self.find_by_login_or_email(login)
    find_by_login(login) || find_by_email(login)
  end  
end
