require 'spec_helper'

describe ListOrderController do
  describe "#create" do
    before do
      @list = Factory(:list)
      @user = Factory(:user)
      
      login_as(@user)
      
      @item = Factory(:item, :list => @list)
      @item2 = Factory(:item, :list => @list)
      @user.lists << @list
      
      # pre assert positions
      @item.position.should == 1
      @item2.position.should == 2
      
      get :create, :items => [ @item2.id.to_s, @item.id.to_s ], :list_id => @list.id
    end
    
    it "should do respond with success" do
      response.should be_success
    end
      
    it "should reorder the items correctly" do
      @item.reload.position.should == 2
      @item2.reload.position.should == 1
    end
    
    it "should not raise an error if an item is included that has been removed" do
      lambda {
        get :create, :items => [ @item2.id.to_s ], :list_id => @list.id
      }.should_not raise_error
    end
    
    it "should not have items with duplicate positions even after a post with an invalid array" do
      get :create, :items => [ @item2.id.to_s ], :list_id => @list.id        
      @item.reload.position.should == 2
      @item2.reload.position.should == 1
    end
  end
end
