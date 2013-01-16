# Supports the "feed" of user updates.
class Blip < ActiveRecord::Base
  composed_of :action_type, :class_name => 'Listable::ActionType', :mapping => [ [ 'action_type_id', 'action_type_id' ] ]
  
  # The user who "caused" this blip by doing something in the system
  belongs_to :originating_user, :class_name => 'User'
  belongs_to :destination_user, :class_name => 'User'
  
  belongs_to :modified_item, :polymorphic => true

  after_create :populate_friend_blips
  
  belongs_to :list
  
  validates_presence_of :list_id
  
  named_scope :for_user, lambda { |user|
    {
      :order    => "created_at DESC",
      :limit    => 10,
      :conditions => ["blips.destination_user_id = ?", user.id]
    }
  }
  
  # Creates a blip for the associated item. Assumes that the modified item has the following methods:
  #  - creator
  def self.create_for(modified_item, action_type, originating_user)
    raise ArgumentError, "Modified item must belong to a list" unless modified_item.respond_to?(:list)
    raise ArgumentError, "Modified item must have a login or a name" unless [ :login, :name ].any?{ |sym| modified_item.respond_to?(sym) }

    aff_ent_name = modified_item.respond_to?(:login) ? modified_item.login : modified_item.name
    
    self.create(  
      :originating_user     => originating_user, 
      :destination_user     => originating_user, 
      :modified_item        => modified_item,
      :action_type          => action_type,
      :list_id              => modified_item.list.id,
      :affected_entity_name => aff_ent_name
    )
  end

  # Only has an effect when the destination user is the same as the originating user.
  # In that case, it finds all users who are concerned with this event, and creates a 
  # blip for that user.  This should never be called in request cycle for performance reasons --
  # it should always be invoked from a worker process.
  def expand_to_concerned_users
    if initial_blip?
      
      # We can't do anything unless it has a list!
      if self.modified_item.respond_to?(:list)
        # For each concerned_user, copy blip attributes, substituting their ID for the destination_user_id    
        concerned_users.each do |u|
          b = Blip.create(self.attributes.except('id').merge(:destination_user_id => u.id))
          
          # Put a message in the outgoing queue if this user has a device id
          unless u.device_token.nil?
            Listable::Apn.new(b, true)
          end
        end
        
      end
    end
  end

  private
  
  # Put our ID on the queue if the originating user is the same as destination.
  # This ID will be read by a worker which will then expand out this blip to all concerned users.
  def populate_friend_blips
    QUEUE.set(NEW_BLIP_QUEUE, self.id) if initial_blip?
  end
  
  def concerned_users
    self.modified_item.list.notifiable_users - [ self.originating_user ]
  end
  
  # A blip is "initial" if it has the same user for both origination and destination.  Special
  # behavior for blip expansion is enacted in these cases.
  def initial_blip?
    !self.destination_user.nil? && !self.originating_user.nil? && self.originating_user == self.destination_user
  end
end
