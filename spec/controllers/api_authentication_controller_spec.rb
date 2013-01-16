require 'spec_helper'

describe ApiAuthenticationController do

  describe "show" do
    before do
      @user = Factory(:user)
    end
    
    it "should return response code 200 when the token is valid" do
      get :show, :id => @user.single_access_token, :format => 'json'
      response.code.should == '200'
      
      JSON.parse(response.body)['message'].should =~ /succeeded/i
    end
    
    it "should return response code 404 when the token is invalid" do
      get :show, :id => 'foobar', :format => 'json'
      response.code.should == '404'
      
      JSON.parse(response.body)['message'].should =~ /failed/i
    end

  end
  
end
