require 'spec_helper'

describe PerishableTokenController do

  describe "#show" do
    before do
      @user = Factory(:user)
      login_as(@user)
      get :show, :format => 'json', :key => @user.single_access_token
    end
    
    it "should change the perishable_token" do
      lambda {
        get :show, :format => 'json', :key => @user.single_access_token
        @user.reload
      }.should change(@user, :perishable_token)
    end
  
    it "should return the perishable_token in attribute key" do
      JSON.parse(response.body)['token'].should == @user.reload.perishable_token
    end
  end

end
