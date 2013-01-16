require 'spec_helper'

describe List do
  before do
    @user = Factory(:user)
    @list = Factory(:list, :creator => @user)
    @user.lists << @list
    Factory(:item, :list => @list, :creator => @user)    
  end

  describe "setting the uuid" do
    it "should have a uuid after creation" do
      Factory(:list).uuid.should =~ /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/
    end
  end

  describe "validation for length of list name" do
    it "should be valid if the name is 1024 chars" do
      @list.name = 'a' * 1024
      @list.should be_valid
    end
    
    it "should not be valid if the name is > 1024 chars" do
      @list.name = 'a' * 1025
      @list.should_not be_valid
    end
  end

  describe "notifiable_users named scope" do
    before do
      @u1 = Factory(:user)
      @u2 = Factory(:user)
      
      @u1.lists << @list
      
      @ull1 = UserListLink.last

      @u2.lists << @list
      @ull2 = UserListLink.last
      @ull2.watching = false ; @ull2.save
    end
    
    it "should return a set of users" do
      @list.notifiable_users.all?{|u| u.is_a?(User)}.should be_true
    end
    
    it "should see a user with watching turned on" do
      @list.notifiable_users.should include(@u1)
    end
    
    it "should not see a user without watching turned on" do
      @list.notifiable_users.should_not include(@u2)
    end
  end

  it "should create a new instance given valid attributes" do
    @list.save!
  end
  
  it "should delete the user_list_links that are attached to the list when the list is deleted" do
    lambda {
      @list.destroy
    }.should change(UserListLink, :count).by(-1)
  end
  
  it "should delete the associated items when a list is deleted" do
    lambda {
      @list.destroy
    }.should change(Item, :count).by(-1)
  end
    
end
