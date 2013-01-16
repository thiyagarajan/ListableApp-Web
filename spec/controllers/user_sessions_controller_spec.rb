require 'spec_helper'

describe UserSessionsController do

  before do
    @user = Factory(:user)
  end
  
  integrate_views
  
  describe "#create" do
    
    # Need to do this for API... allow recheck of password by creating new session, it's fine.
    it "should allow the user to authenticate even if they're logged in" do
      login_as(@user)
      get :create, :format => 'json', :user_session => { :login => @user.login, :password => @user.password }
      response.should be_success
    end
    
    describe "json format" do
      before do
        get :create, :format => 'json', :user_session => { :login => @user.login, :password => @user.password }
      end

      describe "on success" do
        it "should have a code of 200" do
          response.code.should == '200'
        end

        it "should the single access token in the body" do
          JSON.parse(response.body)['token'].should == @user.single_access_token
        end
        
        it "should have the user id" do
          JSON.parse(response.body)['user_id'].should == @user.id
        end
        
        it "should have two keys" do
          JSON.parse(response.body).keys.size.should == 2
        end
      end
      
      describe "on failure" do
        before do
          get :create, :format => 'json', :user_session => { :email => @user.login, :password => 'the wrong password, d00d' }          
        end
        
        it "should have a response code of 404" do
          response.code.should == '404'
        end
        
        it "should have a failure message in the body" do
          JSON.parse(response.body)['message'].should =~ /failed/i
        end
      end
    end
    
    describe "html format" do      
      it "should redirect to the lists path on success" do
        get :create, :user_session => { :login => @user.login, :password => @user.password }
        response.should redirect_to(lists_path)
      end
      
      it "should render the new template on failure" do
        get :create, :user_session => { :email => @user.email, :password => 'the wrong password, d00d' }
        response.should redirect_to(new_user_session_path)
      end
    end
  end
  
end
