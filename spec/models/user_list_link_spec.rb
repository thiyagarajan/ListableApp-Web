require 'spec_helper'

describe UserListLink do
  before do
    @user_list_link = Factory.build(:user_list_link)
  end

  it "should create a new instance given valid attributes" do
    @user_list_link.save!
  end

  describe "ordering" do
    before do
      @user = Factory(:user)
      @list = Factory(:list)
      @user.lists << @list      
    end
    
    it "should start at position 1" do
      @user.user_list_links.first.position.should == 1    
    end
    
    describe "when many items exist" do
      before do
        @user.user_list_links.destroy_all
        list1 = Factory(:list)
        list2 = Factory(:list)
        list3 = Factory(:list)
        list4 = Factory(:list)
      
        @user.lists << list1
        @user.lists << list2
        @user.lists << list3
        @user.lists << list4      
      end
      
      it "should insert items in sequence" do
        @user.user_list_links.each_with_index do |l, i|
          l.position.should == i + 1
        end        
      end

      it "should not leave gaps when items are removed" do
        # pre-assertion
        lambda {
          @user.user_list_links.second.destroy
        }.should change(@user.lists, :count).by(-1)
      
        @user.user_list_links.reload.each_with_index do |l, i|
          l.position.should == i + 1
        end
      end
    end
  end
  
  it "should have an error if a link already exists between a given user and a list" do
    user = Factory(:user)
    list = Factory(:list)
    user.lists << list
    
    lambda {
      user.lists << list
    }.should raise_error(ActiveRecord::RecordInvalid, "Validation failed: List has already been taken")
  end
  
  it "should create a blip after creation" do
    lambda {
      list = Factory(:list)
      user = Factory(:user)
      user.lists << list
    }.should change(Blip, :count).by(1)
  end  
end
