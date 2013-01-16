require 'spec_helper'

describe UserListLinksController do

  describe "update" do
    before do
      @user = Factory(:user)
      @list = Factory(:list)
    end
    
    describe "permissions" do
      it "should respond with a 400 if the user doesn't have permission to the list" do
        another_user = Factory(:user)
        another_user.lists << @list
        get :update, :id => another_user.user_list_links.first.id, :user_list_link => { }, :user_credentials => @user.single_access_token, :format => 'json'
        response.code.should == '403'
      end
      
      it "should respond with a 200 if the user has permission to the list" do
        @user.lists << @list
        get :update, :id => @user.user_list_links.first.id, :user_list_link => { }, :user_credentials => @user.single_access_token, :format => 'json'
        response.code.should == '200'        
      end
    end
    
    describe "updating the item position" do
      before do
        @list2 = Factory(:list)
        
        @link1 = UserListLink.new
        @link1.user = @user
        @link1.list = @list
        @link1.save!
        
        @link2 = UserListLink.new
        @link2.user = @user
        @link2.list = @list2
        @link2.save!
        
        get :update, :id => @link1.id, :user_list_link => { :position => 2 }, :format => 'json', :user_credentials => @user.single_access_token
      end
      
      it "should set the first item to position 2" do
        @link1.reload.position.should == 2
      end
      
      it "should set the second item to position 1" do
        @link2.reload.position.should == 1
      end
    end
  end
  
end
