require 'spec_helper'

describe ListsController do

  before do
    @user = Factory(:user)
    @list = Factory(:list, :creator => @user)
  end
  
  integrate_views

  describe "destroy" do
    
    describe "html format" do
      describe "when a user is logged in" do
        before do
          login_as(@user)
        end
        
        it "should disconnect the list from the user" do
          @user.lists << @list

          @list.save!
          @list.reload
          
          lambda {
            get :destroy, :id => @list.id
          }.should change(@user.user_list_links, :count).by(-1)
        end
  
        it "should not change anything if the user was not associated with the list to begin with" do
          lambda {
            get :destroy, :id => @list.id
          }.should_not change(@user.user_list_links, :count)
        end        
      end
    end
    
    describe "json format" do
      describe "success cases" do
        before do
          @user.lists << @list
          @list.creator = @user
          @list.save ; @list.reload
          
          get :destroy, :id => @list.id, :user_credentials => @user.single_access_token, :format => 'json'
        end
      
        it "should return a response code of 200" do
          response.code.should == '200'
        end
      
        it_should_behave_like "all json actions"
      
        it "should return an empty json message" do
          response.body.should be_an_empty_json_message
        end
      end

      it "should call Listable::LookupByIdOrUuid.lookup_by_id_or_uuid" do
        u = Factory(:user)
        login_as(u)
        list = Factory(:list)
        u.lists << list
        
        List.expects(:lookup_by_id_or_uuid).with(list.id.to_s)
        get :destroy, :id => list.id
      end
      
      describe "failure cases" do

        describe "when user doesn't have access to this list" do
          before do
            @user.user_list_links.destroy_all
            get :destroy, :id => @list.id, :format => 'json', :user_credentials => @user.single_access_token
          end
      
          it "should respond with a failure message 403 Forbidden" do
            response.code.should == "403"
          end
      
          it_should_behave_like "all json actions"

          it "should make available the reason for refusal in the entity" do
            JSON.parse(response.body)['message'].should == "Unable to access requested list"
          end
        end

        describe "when the auth token is wrong" do
          before do
            @user.lists << @list
            get :destroy, :id => @list.id, :user_credentials => 'thewrongtoken!', :format => 'json'
          end

          it "should return a response code of 403" do
            response.code.should == '403'
          end

          it_should_behave_like "all json actions"

          it "should return an empty body" do
            JSON.parse(response.body)['message'].should =~ /invalid/i
          end          
        end
      end
    end

  end

  describe "index" do
    
    describe "success case" do
      before do
        get :index, :format => 'json', :user_credentials => @user.single_access_token
      end

      it_should_behave_like "all json actions"

      it "should respond with a json representation of valid lists for the user" do
        response.should be_success
        response.body.should be_valid_json
      end      
    end

    it "should return the list name id, and link_id for each element" do
      @item = Factory(:item, :list => @list)
      @user.lists << @list
      
      @list.update_attributes!(:creator_id => @user.id)
      get :index, :format => 'json', :user_credentials => @user.single_access_token

      rsp = JSON.parse(response.body)
      rsp.size.should == 1
    
      # Make sure it has no extraneuos elements.
      rsp[0].keys.size.should == 5
    
      rsp[0]['name'].should == @list.name
      rsp[0]['id'].should == @list.id
      rsp[0]['link_id'].should == @user.user_list_links.first(:conditions => {:list_id => @list.id}).id
      rsp[0]['current_user_is_creator'].should == true
    end
    
  end
  
  describe "security" do
    describe "when a user isn't logged in" do
      [:new, :index, :create].each do |sym|
        it "##{sym} should deny access" do
          get sym
          flash[:error].should_not be_nil
          response.should redirect_to(new_user_session_path)
        end
      end      
    end
  end

  describe "update" do
    before do
      login_as(@user)
      @user.lists << @list
    end
    
    describe "on success" do
      before do
        get :update, :format => 'json', :id => @list.id, :list => { :name => 'foo' }
        @json = JSON.parse(response.body)
      end

      it "should update the list name" do
        @list.reload.name.should == "foo"
      end

      it "should have a response code of 200" do
        response.code.should == '200'
      end

      it_should_behave_like "all json actions"

      it "should have only the list name in the body" do
        @json.keys.size.should == 1
        @json['name'].should == 'foo'
      end
    end

    it "should call Listable::LookupByIdOrUuid.lookup_by_id_or_uuid" do
      List.expects(:lookup_by_id_or_uuid).with('4040404')
      get :update, :id => '4040404'
    end

    describe "on failure" do
      before do
        List.expects(:lookup_by_id_or_uuid).returns(@list)
        @list.expects(:update_attributes).returns(false)

        get :update, :format => 'json', :id => @list.id, :list => { :name => 'foo' }
      end

      it_should_behave_like "all json actions"

      it "should have a response code of 400" do
        response.code.should == '400'
      end

      it "should have a failure message in body" do
        response.body.should =~ /fail/i
      end
    end
  end
  
  describe "#create" do
    before do
      login_as(@user)
    end
    
    it "should create a list" do
      lambda {
        get :create, :list => { :name => 'foo' }        
      }.should change(List, :count).by(1)
    end

    # Make sure create action doesn't verify authenticity token as the API 
    # can't do this.  FIX if we can figure out a way to only disable this
    # for json requests for example, then we can improve security.
    it "should not invoke verify_authenticity_token" do
      controller.expects(:verify_authenticity_token).times(0)
      get :create, :list => { :name => 'foo' }
    end
    
    describe "html format" do
      it "should redirect to the list items view" do
        get :create, :list => { :name => 'foo' }
        response.should redirect_to(list_items_path(List.last))
      end
      
      describe "failure cases" do
        before do
          List.stubs(:new).returns(@list)
          @list.expects(:save).returns(false)
        end
        
        it "should render the new template" do
          get :create, :list => { :name => 'foo' }
          response.should render_template(:new)
        end
      end
    end
    
    describe "json" do
      describe "success cases" do
        before do
          get :create, :list => { :name => 'foo' }, :format => 'json'
          @resp = JSON.parse(response.body)
        end
      
        it "should return status code 200 on success" do
          response.code.should == '200'
        end
      
        it_should_behave_like "all json actions"
      
        it "should return the list id in the body" do
          @resp['id'].should == List.last.id
        end
        
        it "should return the list name in the body" do
          @resp['name'].should == List.last.name
        end
        
        it "should return true indicating the current user is creator" do
          @resp['current_user_is_creator'].should == true
        end
      end
      
      describe "when the list name is blank" do
        before do
          get :create, :list => { :name => '' }, :format => 'json'
          @resp = JSON.parse(response.body)
        end

        it_should_behave_like "all json actions"
        
        it "should return a 400 status code" do
          response.code.should == '400'
        end
        
        it "should return a message indicating that blank names are not acceptable" do
          @resp['message'].should =~ /name can't be blank/i
        end
      end
            
      describe "failure case" do
        before do
          List.stubs(:new).returns(@list)
          @list.expects(:save).returns(false)
          get :create, :list => { :name => 'foo' }, :format => 'json'
        end
        
        it_should_behave_like "all json actions"
        
        it "should return a 400 code" do
          response.code.should == '400'
        end
        
        it "should have a failure message in body" do
          JSON.parse(response.body)['message'].should =~ /unable/i
        end
      end
    end
  end

end
