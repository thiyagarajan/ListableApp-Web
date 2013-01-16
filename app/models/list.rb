class List < ActiveRecord::Base
  attr_accessible :name
  
  has_many :items, :dependent => :destroy
  
  has_many :user_list_links, :dependent => :destroy
  has_many :users, :through => :user_list_links
  has_many :blips, :as => :modified_item
  
  has_many :notifiable_users, :source => :user, :through => :user_list_links, :conditions => ['user_list_links.watching = ?', true]
  
  belongs_to :creator, :class_name => 'User'
    
  validates_presence_of :name
  validates_length_of :name, :in => 1..1024

  validates_presence_of :uuid  

  validates_presence_of :creator
  validates_associated :creator

  extend Listable::LookupByIdOrUuid

  default_value_for :uuid do
    Listable::Uuid.generate
  end
  
end
