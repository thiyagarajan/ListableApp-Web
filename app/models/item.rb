class Item < ActiveRecord::Base
  attr_accessible :name, :position, :completed
  
  named_scope :active,  :conditions => { :completed => false  }
  named_scope :completed,  :conditions => { :completed => true  }

  named_scope :ordered_by_completed_status_and_position, :order => 'completed, position'

  named_scope :sorted_alphabetically, :order => :name

  named_scope :with_name_like, lambda { |keyword|
    {
      :conditions => ["#{self.table_name}.name LIKE ?", "%#{keyword}%"]
    }
  }

  has_many :blips, :as => :modified_item
  
  belongs_to :list
    
  belongs_to :creator, :class_name => 'User'    

  validates_presence_of :name
  validates_length_of :name, :in => 1..1024
  
  validates_exclusion_of :position, :in => [ 0 ], :message => "must not be 0"
  
  validates_presence_of :list_id
  validates_associated :list

  validates_presence_of :uuid

  after_create :create_blip

  after_save :create_completed_status_changed_blips

  acts_as_list :scope => 'list_id = #{list_id} AND completed = #{completed}'
  
  attr_reader :changed_by

  default_value_for :uuid do
    Listable::Uuid.generate
  end

  def changed_by=(user)
    raise ArgumentError, "Modifying agent must be a User" unless user.is_a?(User)
    @changed_by = user
  end
  
  def after_save
    # Check position_changed so that we don't go into infinite loop when the plugin saves
    # this record. We also don't want to muck around with the position if someone else is 
    # playing with it.
    if completed_changed? && !position_changed?
      
      # Change completed to previous value so that it can be removed from the correct list
      # by the plugin.
      self.completed = !self.completed
      self.remove_from_list
      
      # Re-set the completed value to the correct one.
      self.completed = !self.completed
      
      # Re-insert in the correct list.
      self.insert_at(1)
    end    
  end

  def active?
    !completed?
  end

  private
  
  def create_blip
    Blip.create_for(self, Listable::ActionType.new(1), self.creator)
  end

  def create_completed_status_changed_blips
    if self.completed_changed? && !position_changed?
      action_type_id = self.completed? ? 2 : 3
      Blip.create_for(self, Listable::ActionType.new(action_type_id), @changed_by)
    end
  end
end
