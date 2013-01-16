require 'spec_helper'

describe UsernamesController do
  before do
    @user = Factory(:user)
  end
  
  integrate_views

  describe "#edit" do
    before do
      login_as(@user)
    end
    
    it "should be successful" do
      get :edit, :id => @user.id
      response.should be_success
    end
  end
  
  describe "#update" do
    before do
      login_as(@user)
    end
    
    it "should change the username" do
      get :update, :user => {:login => 'hank' }
      @user.reload.login.should == 'hank'
    end
  end
end
