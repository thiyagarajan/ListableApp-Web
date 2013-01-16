require 'spec_helper'

describe ItemsController do
  before do
    @user = Factory(:user)
    @list = Factory(:list)
  end
  
  integrate_views
  
  describe "#show" do
    describe "with json format" do
      
      describe "when the record can't be found" do
        before do
          item = Factory(:item, :list => @list)

          item_id = item.id
          item.destroy
          @user.lists << @list
          get :show, :id => item_id, :list_id => @list.id, :user_credentials => @user.single_access_token, :format => 'json'
        end
        
        it_should_behave_like "all json actions"
        
        it "should return a 404" do
          response.should be_missing
        end
        
        it "should have content in the message field" do
          JSON.parse(response.body)['message'].should =~ /record not found/i
        end        
      end

      it "should be able to find an item by uuid" do
        item = Factory(:item, :list => @list)
        @user.lists << @list
        get :show, :id => item.uuid, :list_id => @list.uuid, :user_credentials => @user.single_access_token, :format => 'json'
        assigns[:item].should == item
      end

      describe "security" do
        
        describe "when the user doesn't own the list requested" do
          before do
            @item = Factory(:item, :list => @list)
            get :show, :list_id => @list.id, :id => @item.id, :format => 'json', :user_credentials => @user.single_access_token
          end
          
          it_should_behave_like "all json actions"
          
          it "should return a code of 403" do
            response.code.should == '403'
          end

          it "should return a message saying the user doesn't have permission for the list" do
            JSON.parse(response.body)['message'].should =~ /Unable to access requested list/i
          end
        end

        describe "sneaky attempts to show an item" do
          before do
            @user.lists << @list
            login_as(@user)            
            other_item = Factory(:item, :list => Factory(:list))
            get :show, :list_id => @list.id, :id => other_item.id
          end

          it "should respond as if it couldn't find the object" do
            response.should be_missing
          end
        end

        describe "when the user doesn't provide a valid auth token" do
          before do
            @user.lists << @list
            item = Factory(:item, :list => @list)

            get :show, :list_id => @list.id, :id => item.id, :format => 'json'
          end
          
          it_should_behave_like "all json actions"
          
          it "should return a code of 403" do
            response.code.should == '403'
          end

          it "should return a message saying the user doesn't have permission for the list" do
            JSON.parse(response.body)['message'].should =~ /token may be invalid/i
          end
        end
      end
            
      describe "success output" do
        before do
          @user.lists << @list
          @item = Factory(:item, :list => @list)

          @item.creator = @user
          @item.save!

          get :show, :id => @item.id, :list_id => @list.id, :user_credentials => @user.single_access_token, :format => 'json'
          @json = JSON.parse(response.body)
        end
        
        it_should_behave_like "all json actions"
        
        it "should have a type of 'Item'" do
          @json['type'].should == 'Item'
        end
        
        it "should have an ID" do
          @json['id'].should == @item.id
        end
        
        it "should have a name" do
          @json['name'].should == @item.name
        end
        
        it "should have a creator_login" do
          @json['creator_login'].should == @item.creator.login
        end
        
        it "should have a created_at" do
          DateTime.parse(@json['created_at']).should == DateTime.parse(@item.created_at.to_s)
        end
        
        it "should only have 6 keys" do
          @json.keys.size.should == 6
        end
        
        it "should return a key for creator email even when the creator is nil" do
          @item.creator = nil
          @item.save ; @item.reload
          
          get :show, :id => @item.id, :list_id => @list.id, :user_credentials => @user.single_access_token, :format => 'json'
          JSON.parse(response.body).keys.should include('creator_login')
        end
      end
    end
  end
  
  describe "#index" do
    before do
      @user.lists << @list
    end

    describe "rendering HTML index" do
      it "should render successfully" do
        login_as(@user)
        get :index, :list_id => @list.id
      end
    end

    describe "json interface" do
      it "should respond successfully" do
        get :index, :format => 'json', :list_id => @list.id, :user_credentials => @user.single_access_token
        response.should be_success
      end

      describe "general json actions" do
        before do
          get :index, :format => 'json', :list_id => @list.id, :user_credentials => @user.single_access_token
        end
        it_should_behave_like "all json actions"
      end

      it "should return the list name and the id for each element" do
        item = Factory(:item, :list => @list)

        get :index, :format => 'json', :list_id => @list.id, :user_credentials => @user.single_access_token
        
        rsp = JSON.parse(response.body)
        rsp.size.should == 1
      
        # Make sure it has no extraneuos elements.
        rsp[0].keys.size.should == 5
      
        rsp[0]['name'].should == item.name
        rsp[0]['id'].should == item.id
        rsp[0]['position'].should == item.position
      end

      describe "when the resource is not available" do
        before do
          @bad_id = @list.id
          @list.destroy
          get :index, :list_id => @bad_id, :format => 'json', :user_credentials => @user.single_access_token
        end
        
        it "should return a status 404" do
          response.status.should == '404 Not Found'
        end
        
        it "should return a body with a useful message" do
          JSON.parse(response.body)['message'].should == "Unable to find list with id requested."
        end
      end

      describe "sorting results" do
        describe "rendering JSON index" do
          it "should render successfully" do
            get :index, :list_id => @list.id, :format => 'json', :user_credentials => @user.single_access_token
            response.should be_success
          end

          it "should return a JSON array the same size as the list items collection" do
            get :index, :list_id => @list.id, :format => 'json', :user_credentials => @user.single_access_token
            JSON.parse(response.body).size.should == @list.items.size
          end
        end

        describe "sorting" do
          it "should sort according to item priority by default" do
            item1 = Factory(:item, :list => @list, :name => 'Elephant')
            item2 = Factory(:item, :list => @list, :name => 'Aardvark')

            get :index, :list_id => @list.id, :format => 'json', :user_credentials => @user.single_access_token
            JSON.parse(response.body).map{|i| i['id']}.should == [ item1, item2 ].map(&:id)
          end

          it "should sort by priority when specified" do
            item1 = Factory(:item, :list => @list, :name => 'Elephant')
            item2 = Factory(:item, :list => @list, :name => 'Aardvark')

            get :index, :list_id => @list.id, :sort => 'Priority', :format => 'json', :user_credentials => @user.single_access_token
            JSON.parse(response.body).map{|i| i['id']}.should == [ item1, item2 ].map(&:id)
          end

          it "should allow sorting by alphabetical order when specified" do
            item1 = Factory(:item, :list => @list, :name => 'Elephant')
            item2 = Factory(:item, :list => @list, :name => 'Aardvark')

            get :index, :list_id => @list.id, :sort => 'Alphabetical', :format => 'json', :user_credentials => @user.single_access_token
            JSON.parse(response.body).map{|i| i['id']}.should == [ item2, item1 ].map(&:id)
          end
        end

        describe "filtering" do
          it "should return all records by default" do
            item1 = Factory(:item, :list => @list, :name => 'Elephant')
            item2 = Factory(:item, :list => @list, :name => 'Aardvark')

            get :index, :list_id => @list.id, :format => 'json', :user_credentials => @user.single_access_token
            JSON.parse(response.body).map{|i| i['id']}.sort.should == [ item2, item1 ].map(&:id).sort
          end

          it "should return results filtered by keyword when specified" do
            item1 = Factory(:item, :list => @list, :name => 'Elephant')
            item2 = Factory(:item, :list => @list, :name => 'Aardvark')

            get :index, :list_id => @list.id, :keyword => 'Elephant', :format =>'json', :user_credentials => @user.single_access_token
            JSON.parse(response.body).map{|i| i['id']}.should == [ item1 ].map(&:id)
          end
        end
      end
    end
  end
    
  describe "#update" do
    before do
      login_as(@user)
      @user.lists << @list
      @item = Factory(:item, :list => @list)
    end
    
    describe "on success" do

      describe "reordering" do
        before do
          Item.stubs(:find).returns(@item)
          @pos = 1
        end
        
        it "should call #insert_at when the position attribute is included in params" do
          @item.expects(:insert_at).with(@pos).once
          get :update, :list_id => @list.id, :id => @item.id, :item => { :position => @pos }
        end
        
        it "should remove the position argument from the params hash" do
          @item.expects(:attributes=).with({'name' => 'foo'}).once
          get :update, :list_id => @list.id, :id => @item.id, :item => { :position => @pos, :name => 'foo' }
          @item.reload.position.should == @pos
        end
        
        it "should not call #insert_at when the position attribute is not included in params" do
          @item.expects(:insert_at).with(@pos).never
          lambda {
            get :update, :list_id => @list.id, :id => @item.id, :item => { }            
          }.should_not change(@item, :position)
        end        
      end
      
      describe "json format" do
        before do
          get :update, :format => 'json', :list_id => @list.id, :id => @item.id, :item => { :name => 'foo' }, :user_credentials => @user.single_access_token
        end

        it "should have a response code of 200" do
          response.code.should == '200'
        end

        it_should_behave_like "all json actions"

        it "should create a blip with the correct originating user" do
          lambda {
            get :update, :list_id => @list.id, :id => @item.id, :item => { :name => 'foo', :completed => !@item.completed }
          }.should change(Blip, :count).by(1)

          Blip.last.originating_user.should == @user
        end

        it "should update the item name" do
          @item.reload.name.should == "foo"
        end

        it "should have one key containing the name in the body" do
          json = JSON.parse(response.body)
          json.keys.size.should == 1
          json['name'].should == 'foo'
        end
      end

      describe "html format" do
        before do
          get :update, :format => 'html', :list_id => @list.id, :id => @item.id, :item => { :name => 'foo' }
        end

        it "should have a response code of 302" do
          response.code.should == '302'
        end

        it "should update the item name" do
          @item.reload.name.should == "foo"
        end

        it "should redirect to the list path path" do
          response.should redirect_to(list_items_path(@list))
        end

        it "should redirect to the list path path on failure" do
          get :update, :format => 'html', :list_id => @list.id, :id => @item.id, :item => { :name => '' }
          response.should redirect_to(list_items_path(@list))
        end
      end
    end

    describe "sneaky attempts to update an item" do
      before do
        @other_item = Factory(:item, :name => 'old name', :list => Factory(:list))
        get :update, :list_id => @list.id, :id => @other_item.id, :item => { :name => 'new name' }
      end

      it "should not be able to update an item on an unrelated list" do
        @other_item.reload.name.should == 'old name'
      end

      it "should respond as if it couldn't find the object" do
        response.should be_missing        
      end
    end

    describe "on failure" do
      before do
        Item.expects(:find).returns(@item)
        @item.expects(:save).returns(false)
      end

      describe "json format" do
        before do
          get :update, :format => 'json', :list_id => @list.id, :id => @item.id, :item => { :name => 'foo' }
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
  end
  
  describe "#destroy" do
    before do
      @item = Factory(:item, :list => @list)
    end
                                                
    describe "html format" do
      
      describe "failure cases" do
        it "should not destroy an item when it doesn't belong to given list id" do
          list2 = Factory(:list)
          @item.list = list2
          @item.save ; @item.reload
          @list.items.should_not include(@item) # pre-assertion
          
          lambda {
            get :destroy, :list_id => @list.id, :id => @item.id
          }.should_not change(@list.items, :count)
        end
        
        it "should render a 404 page" do
          login_as(@user)
          @user.lists << @list
          item_id = @item.id
          @item.destroy
          
          get :destroy, :list_id => @list.id, :id => item_id
          response.should be_missing
        end
      end
      
      describe "on success" do
        before do
          login_as(@user)
          @user.lists << @list
          @list.items << @item
        end
        
        it "should reduce list item count by 1" do
          lambda {
            get :destroy, :list_id => @list.id, :id => @item.id
          }.should change(@list.items, :count).by(-1)
        end
    
        describe "response" do
          before do
            get :destroy, :list_id => @list.id, :id => @item.id
          end
          
          it "should redirect to the list items path" do
            response.should redirect_to(list_items_path(@list))
          end
        end
      end      
    end
    
    describe "json format" do
      describe "on success" do
        before do
          @user.lists << @list
          
          get :destroy, :format => 'json', :list_id => @list.id, :id => @item.id, :user_credentials => @user.single_access_token          
        end
        
        it "should return status code 200" do
          response.code.should == '200'
        end

        it_should_behave_like "all json actions"

        it "should return an empty json message" do
          response.body.should be_an_empty_json_message
        end
      end
      
      describe "on failure" do
        before do
          @user.lists << @list
          
          Item.stubs(:first).returns(@item)

          @item.expects(:destroy).returns(false)
          
          get :destroy, :format => 'json', :list_id => @list.id, :id => @item.id, :user_credentials => @user.single_access_token
        end
        
        it_should_behave_like "all json actions"
        
        it "should return status code 400" do
          response.code.should == '400'
        end
        
        it "should return an json message about the deletion failure" do
          JSON.parse(response.body)['message'].should == "Resource could not be deleted"
        end
      end
    end
  end
  
  describe "#create" do
    before do
      login_as(@user)
    end
    
    it "should create an item when user has permission to the list" do
      @user.lists << @list
      lambda {
        get :create, :list_id => @list.id, :item => { :name => "An item" }
      }.should change(Item, :count).by(1)
    end
    
    it "should not create an item when user doesn't have permission to the list" do
      lambda {
        get :create, :list_id => @list.id, :item => { :name => "An item" }
      }.should_not change(Item, :count)
    end
    
    describe "json" do
      before do
        @user.lists << @list
      end
      
      describe "on success" do
        before do
          get :create, :list_id => @list.id, :item => { :name => "An item" }, :format => 'json', :user_credentials => @user.single_access_token
        end
      
        it "should return status code 200 on success" do
          response.code.should == '200'
        end
      
        it_should_behave_like "all json actions"

        it "should return an empty json message success" do
          response.body.should be_an_empty_json_message
        end
      end
      
      describe "when the item name is blank" do
        before do
          get :create, :list_id => @list.id, :item => { :name => '' }, :format => 'json', :user_credentials => @user.single_access_token
          @resp = JSON.parse(response.body)
        end

        it_should_behave_like "all json actions"
        
        it "should return a 400 status code" do
          response.code.should == '400'
        end
        
        it "should return a message indicating that blank names are not acceptable" do
          @resp['message'].should =~ /Resource could not be created/i
        end
      end
      
      describe "on failure" do
        before do
          @item = Factory(:item, :list => @list)
          
          Item.expects(:new).returns(@item)
          @item.expects(:save).returns(false)
          get :create, :format => 'json', :list_id => @list.id, :item => { :name => "An item" }, :format => 'json', :user_credentials => @user.single_access_token
        end
        
        it "should return an error code of 400" do
          response.code.should == '400'
        end
        
        it_should_behave_like "all json actions"
        
        it "should say that the resource could not be saved" do
          JSON.parse(response.body)['message'].should =~ /could not be created/
        end
      end
    end
  end
  
  describe "security redirects and error settings" do

    describe "allowing access for a user to a resource that they're allowed to see" do
      before do
        @user.lists << @list
        @item = Factory(:item, :list => @list)
        login_as(@user)
      end
      
      it "should allow access to index" do
        get :index, :list_id => @list.id
        response.should be_success
      end
      
      it "should allow access to update" do
        get :update, :list_id => @list.id, :id => @item.id, :item => { }
        response.should be_success
      end
      
      it "should allow access to destroy" do
        get :destroy, :list_id => @list.id, :id => @item.id
        response.should redirect_to(list_items_path(@list))
      end
      
      it "should allow access to create" do
        get :create, :list_id => @list.id, :item => { :name => "An item" }
        redirect_to list_items_path(@list)
      end
      
    end
  end

end
