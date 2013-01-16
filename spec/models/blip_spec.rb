require 'spec_helper'

describe Blip do
  before do
    @blip = Factory(:blip, :list => Factory(:list))
  end
  
  describe "##for_user named scope" do
    before do
      @user = Factory(:user)
    end
    it "should take two args" do
      Blip.for_user(@user)
    end
  end
  
  describe "initialization" do
    it "should create a new instance given valid attributes" do
      @blip.should be_valid
    end
  
    it "should have an ActionType" do
      @blip.action_type.should be_a(Listable::ActionType)
    end
  
    it "should have an action type id" do
      @blip.action_type_id.should == 1
    end
  
    it "should have a name for the action type" do
      @blip.action_type.name.should == "Add item"
    end
  end
  
  describe "#affected_entity_name" do
    it "should return the name of the modified item if it has one" do
      item = Factory(:item, :list => Factory(:list))
      blip = Blip.create_for(item, Listable::ActionType.new(1), Factory(:user))
      blip.affected_entity_name.should == item.name
    end
    
    it "should return the email of the modified item if it has no name" do
      ull = Factory(:user_list_link)
      blip = Factory(:blip, :modified_item => ull, :list => Factory(:list))
      blip.affected_entity_name == ull.login
    end
  end
  
  describe "##create_for" do
    before do
      @u = Factory(:user)
      @ou = Factory(:user)
      @l = Factory(:list)
      @i = Factory(:item, :creator => @u, :list => @l)
      @b  = Blip.create_for(@i, Listable::ActionType.new(1), @ou)      
    end
    
    it "should set the originating user to item owner" do
      @b.originating_user.should == @ou
    end
    
    it "should set the destination user to item owner" do
      @b.destination_user.should == @ou
    end
    
    it "should set the modified item to the item" do
      @b.modified_item.should == @i
    end
    
    it "should set the action type to the given type" do
      @b.action_type.action_type_id.should ==  Listable::ActionType.new(1).action_type_id
    end    
    
    it "should keep a denormalized reference to the list" do
      @b.list.should == @l
    end
  end
  
  describe "#populate_friend_blips" do
    before do
      @user = Factory(:user)
    end
    
    it "should add an element to the new blip queue with id of self" do
      b = Factory.build(:blip, :originating_user => @user, :destination_user => @user, :list => Factory(:list))
      QUEUE.expects(:set)
      b.save!
    end
  end
  
  describe "#expand_to_concerned_users" do
    before do
      @list = Factory(:list)
      
      @user1 = Factory(:user)
      @user2 = Factory(:user)
      
      # Creates a blip for originating user in callback
      @item = Factory(:item, :creator => @user1, :list => @list)
      
      @blip = Blip.last
      
      @list.users << @user1
      @list.users << @user2
      
      @item.creator = @user2
      @item.save ; @item.reload
    end
    
    it "should create a blip for every user associated with the list attached to the modified_item" do
      lambda {
        @blip.expand_to_concerned_users
      }.should change(Blip, :count).by(1)
    end
    
    describe "attributes on created blip" do
      before do
        @blip.expand_to_concerned_users
        @new_blip = Blip.last
      end

      it "should set the destination user to the non-creator user" do
        @new_blip.destination_user.should == @user2
      end
      
      it "should set the action type to the same type as the original blip" do
        @new_blip.action_type_id.should == @blip.action_type_id
      end
    end
    
  end
end
