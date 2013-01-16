require 'spec_helper'

describe UsersController do
  before do
    @user = Factory(:user)
  end
  
  integrate_views
  
  describe "show" do
    describe "when a user is logged in" do
      before do
        login_as(@user)
        get :show
      end
    
      it "should respond successfully" do
        response.should be_success
      end
    end
  end
  
  describe "#create" do
    it "should create a user account if the account didn't exist" do
      lambda {
        get :create, :user => {:email => 'joeblow@example.com', :login => 'joeblow', :password => 'somepass', :password_confirmation => 'somepass' }
      }.should change(User, :count).by(1)
      response.should redirect_to(root_url)
    end  
    
    describe "when new user params are invalid" do
      before do
        get :create, :user => {:email => 'joeblow@example.com', :login => 'joeblow', :password => 'somepass', :password_confirmation => 'anotherpass' }        
      end
      
      it "should render the new template" do
        response.should render_template('new')
      end
      
      it "should have an error in the body regarding the password confirmation" do
        response.body =~ /Password doesn't match confirmation/
      end
    end
    
    describe "trying to set a login that has already been taken" do
      before do
        @u2 = Factory(:user, :confirmed => false, :creator => @user)
      end
      
      it "should not raise an error" do
        lambda {
          get :create, :user => {:email => @u2.email, :login => @user.login, :password => 'somepass', :password_confirmation => 'somepass' }
        }.should_not raise_error
      end
      
      it "should render the new account page" do
        get :create, :user => {:email => @u2.email, :login => @user.login, :password => 'somepass', :password_confirmation => 'somepass' }
        response.should render_template("new")
      end

      it "should render errors" do
        get :create, :user => {:email => @u2.email, :login => @user.login, :password => 'somepass', :password_confirmation => 'somepass' }
        response.body.should =~ /Login has already been taken/
      end    
    end
    
    describe "locking user attributes for an account that was already confirmed" do
      before do
        @user.update_attributes(:login => 'crap')        
      end
      
      it "should not be able to modify the password for a user that already exists when the creator_id is nil" do  
        get :create, :user => {:email => @user.email, :login => 'bunk', :password => 'somepass', :password_confirmation => 'somepass' }
        @user.reload.login.should == 'crap'
      end
      
      it "should not be able to modify the password for a user that already exists when the creator_id is not nil" do
        @user.creator = Factory(:user)
        @user.save!
        
        get :create, :user => {:email => @user.email, :login => 'bunk', :password => 'somepass', :password_confirmation => 'somepass' }
        @user.reload.login.should == 'crap'
      end
      
      it "should allow the attributes to be updated when the user is not confirmed and the user has a creator" do
        @user.creator = Factory(:user)
        @user.confirmed = false
        @user.save!
        
        get :create, :user => {:email => @user.email, :login => 'bunk', :password => 'somepass', :password_confirmation => 'somepass' }
        @user.reload.login.should == 'bunk'        
      end
    end
    
  end  
  
end
