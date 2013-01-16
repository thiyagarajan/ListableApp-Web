require 'spec_helper'

describe DeviceTokenController do
  describe "#update" do
    before do
      @user = Factory(:user)
      @user.device_token.should be_nil
    end
    
    it "should update the device token for the auth key given" do
      get :update, :device_token => "a3eha3eha3eha3eh", :user_credentials => @user.single_access_token, :format => 'json'
      @user.reload.device_token.should == "a3eha3eha3eha3eh"
    end
    
    it "should set the device_registered_at" do
      get :update, :device_token => "a3eha3eha3eha3eh", :user_credentials => @user.single_access_token, :format => 'json'      
      @user.reload
      @user.device_registered_at.should_not be_nil
      @user.device_registered_at.should < DateTime.now
    end
    
    it "should nillify any other user device tokens with the same id" do
      @user.update_attributes(:device_token => '23')
      u2 = Factory(:user, :device_token => '23')
      
      User.count(:conditions => {:device_token => '23'}).should == 2
      get :update, :device_token => "23", :user_credentials => @user.single_access_token, :format => 'json'
      
      User.count(:conditions => {:device_token => '23'}).should == 1
      @user.reload.device_token.should == '23'
      u2.reload.device_token.should be_nil
    end
  end
end
