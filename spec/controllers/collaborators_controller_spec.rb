require 'spec_helper'

describe CollaboratorsController do
  before do
    @list = Factory(:list)
    @user = Factory(:user)
    @list.users << @user  
  end
  
  integrate_views
  
  describe "index" do
    describe "success behavior" do
      before do
        login_as(@user)        
      end
      
      it "should respond successfully" do
        get :index, :list_id => @list.id
        response.should be_success
      end


      describe "json output" do
        before do
          get :index, :list_id => @list.id, :format => 'json'
          @json_response = JSON.parse(response.body)
        end
            
        it "should respond successfully" do
          response.should be_success
        end
      
        it "should fetch a list in valid JSON when requested" do
          @json_response.size.should == 1
        end
      
        it "should contain a hash with emails and ids and creator status" do
          @json_response.first['id'].should == @user.user_list_links.first.id
          @json_response.first['login'].should == @user.login
          @json_response.first['is_creator'].should == false
          @json_response.first['user_image'].should == Digest::MD5.hexdigest(@user.email)
          @json_response.first['user_id'].should == @user.id
        end
        
        it_should_behave_like "all json actions"        
      end
    end
  end
  
  describe "new" do
    describe "success behavior" do
      before do 
        login_as(@user)
      end
      
      it "should render successfully" do
        get :new, :list_id => @list.id
        response.should be_success
      end
    end
  end
  

  describe "create" do
    describe "when the user is not logged in" do
      it "should redirect to the new_session_path" do
        get :create, :list_id => @list.id, :collaborator => { :email => 'justin@example.com' }
        response.should redirect_to new_user_session_path
      end
    end
    
    describe "when the user doesn't have an association with the list" do
      before do
        login_as(@user)
        @user.user_list_links.destroy_all
      end
      
      it "should redirect to the root" do
        get :create, :list_id => @list.id, :collaborator => { :email => 'justin@example.com' }
        response.should redirect_to('/')
      end
      
    end
    
    describe "when the user is logged in" do
      before do
        login_as(@user)
      end
      
      it "should increase the count of users for the list by 1" do
        lambda {
          get :create, :list_id => @list.id, :collaborator => { :email => 'justin@example.com' }
        }.should change(@list.users, :count).by(1)
      end
      
      describe "rendering json" do
        before do
          get :create, :list_id => @list.id, :collaborator => { :email => 'justin@example.com' }, :format => 'json'          
        end
        
        it "should return a response code of 200" do
          response.code.should == '200'
        end
        
        it "should return an empty body" do
          response.body.should be_an_empty_json_message
        end

        it_should_behave_like "all json actions"
      end

      describe "when the user can't be added" do
        before do
          login_as(@user)
        end

        it "should set flash[:error] to 'User joe@blow.com has already been added to this list' when the link was previously created" do
          new_user = Factory(:user, :email => 'joe@blow.com')
          @list.users << new_user

          get :create, :list_id => @list.id, :collaborator => { :email => 'joe@blow.com' }
          flash[:error].should == "User joe@blow.com has already been added to this list."
        end

        it "should set flash[:error] to 'An unknown error occurred' when another error happens" do
          controller.stubs(:create_user_list_link).returns(false)
          get :create, :list_id => @list.id, :collaborator => { :email => 'joe@blow.com' }

          flash[:error].should == 'An unknown error has occurred'
        end
      end
    end
    
    describe "when the user exists" do
      before do
        @u2 = Factory(:user)
      end
      
      it "should save the record and return 200" do
        get :create, :list_id => @list.id, :collaborator => { :email => @u2.email }, :user_credentials => @user.single_access_token, :format => 'json'
        response.code.should == '200'
        response.body.should be_valid_json
      end
      
      it "should not increase the user count" do
        lambda {
          get :create, :list_id => @list.id, :collaborator => { :email => @u2.email }, :user_credentials => @user.single_access_token, :format => 'json'          
        }.should_not change(User, :count)
      end
    end

    describe "failure cases" do
      before do
        controller.expects(:create_user_list_link).returns(false)
      end
      
      describe "html format" do
        before do
          login_as(@user)
          get :create, :list_id => @list.id, :collaborator => { :email => 'justin@example.com' }
        end
        
        it "should render the new template" do
          response.should render_template(:new)
        end
      end
      
      describe "json format" do
        before do
          get :create, :format => 'json', :list_id => @list.id, :collaborator => { :email => 'justin@example.com' }, :user_credentials => @user.single_access_token
        end
        
        it "should return a status of 400" do
          response.code.should == '400'
        end
        
        it "should return a failure message" do
          response.body.should =~ /Unable to subscribe/i
        end
        
        it_should_behave_like "all json actions"
      end
    end
  end  
  
  describe "destroy" do
    describe "failure cases" do
      describe "json failure to delete record" do
        before do
          @user2 = Factory(:user)
          @list.users << @user2
          
          @link = @user2.user_list_links.first
          
          UserListLink.stubs(:find).returns(@link)
          @link.expects(:destroy).returns(false)
          
          get :destroy, :format => 'json', :list_id => @list.id, :id => @link.id, :user_credentials => @user.single_access_token
        end
        
        it "should return status code 400" do
          response.code.should == '400'
        end
        
        it "should return an empty body" do
          JSON.parse(response.body)['message'].should == "Resource could not be deleted"
        end
      end      
    end
    
    describe "success cases" do
      before do
        login_as(@user)
        
        @user2 = Factory(:user)
        @list.users << @user2
        @link = @user2.user_list_links.first
      end
      
      it "should delete the association between the user and the list" do
      
        lambda {
          get :destroy, :list_id => @list.id, :id => @link.id
        }.should change(@user2.lists, :count).by(-1)
      
        response.should redirect_to(list_collaborators_path(@list))
      end
    
      describe "json format" do
        before do
          get :destroy, :list_id => @list.id, :id => @link.id, :user_credentials => @user.single_access_token, :format => 'json'
        end
        
        it "should return a response code of 200" do
          response.code.should == '200'
        end
        
        it "should return an empty json message" do
          response.body.should be_an_empty_json_message
        end
      end
    end
    
  end
end
