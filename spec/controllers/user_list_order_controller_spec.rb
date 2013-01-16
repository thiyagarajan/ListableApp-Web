require 'spec_helper'

describe UserListOrderController do
  describe "#create" do
    before do
      @list1 = Factory(:list)
      @list2 = Factory(:list)
      
      @user = Factory(:user)
      
      login_as(@user)
      
      @user.lists << @list1
      @user.lists << @list2
      
      @first_link = @user.user_list_links.first
      @second_link = @user.user_list_links.second
      
      # pre assert positions
      @first_link.position.should == 1
      @second_link.position.should == 2
      
      get :create, :"movable-user-list" => [ @second_link.id.to_s, @first_link.id.to_s ]
    end
    
    it "should do respond with success" do
      response.should be_success
    end
      
    it "should reorder the items correctly" do
      @first_link.reload.position.should == 2
      @second_link.reload.position.should == 1
    end
  end  
end
