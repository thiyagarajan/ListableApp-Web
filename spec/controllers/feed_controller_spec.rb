require 'spec_helper'

describe FeedController do

  describe "#index" do
    before do
      @user = Factory(:user)
      login_as(@user)
      
      @orig_user = Factory(:user)
      @list = Factory(:list)
      @item = Factory(:item, :list => @list)
      
      @blip = Blip.create_for(@item, Listable::ActionType.new(1), @orig_user)

      @blip.destination_user = @user
      @blip.save!

      get :show, :format => 'json', :user_credentials => @user.single_access_token
      @resp = JSON.parse(response.body)
    end

    it "should have a successful response" do
      response.should be_success
    end
    
    it "should have one element in the json result" do
      @resp.size.should == 1
    end
    
    it "should have a user_image" do
      @resp.first['user_image'].should == Digest::MD5.hexdigest(@blip.originating_user.email)
    end
    
    it "should have a message" do
      @resp.first['message'].should == "'#{@item.name}' was added by #{@blip.originating_user.login} on #{@list.name}."
    end
    
    it "should have 4 keys" do
      @resp.first.keys.size.should == 4
    end
    
    it "should have a key for when the event occurred" do
      @resp.first['time_ago'].should == "less than a minute"
    end
    
    it "should have a key for affected list" do
      @resp.first['list'].should be_a(Hash)
      @resp.first['list']['id'].should == @list.id
      @resp.first['list']['name'].should == @list.name
    end    
  end
  
end