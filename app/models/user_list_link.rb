class UserListLink < ActiveRecord::Base
  # We never use #update_attributes on this model.
  attr_accessible [ ]
  
  belongs_to :user
  belongs_to :list
  
  delegate :login, :to => :user
  delegate :email, :to => :user
  
  belongs_to :creator, :class_name => 'User'
  
  has_many :blips, :as => :modified_item
  
  validates_exclusion_of :position, :in => [ 0 ], :message => "must not be 0"
  validates_uniqueness_of :list_id, :scope => :user_id
  
  acts_as_list :scope => :user_id
  
  after_create :create_blip
  
  private
  
  def create_blip
    Blip.create_for(self, Listable::ActionType.new(4), self.creator)
  end
end
