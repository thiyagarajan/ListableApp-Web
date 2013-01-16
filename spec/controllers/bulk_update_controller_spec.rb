require 'spec_helper'

describe BulkUpdateController do
  describe "#update" do
    before do
      @user = Factory(:user)
      @list = Factory(:list)

      @list.items.create(:name => 'item1')
      @list.items.create(:name => 'item2')

      @user.lists << @list
      
      login_as(@user)
    end

    describe "deleting items" do
      it "should remove selected items" do
        get :update, :apply => 'Delete', :items => @list.items.map{|i| i.id}, :list_id => @list.id
        @list.reload.items.size.should == 0
      end
    end

    describe "completing items" do
      it "should complete selected items" do
        get :update, :apply => 'Complete', :items => @list.items.map{|i| i.id}, :list_id => @list.id
        @list.reload.items.each{|i|i.should_not be_active }
      end
    end

    describe "uncompleting items" do
      it "should uncomplete selected items" do
        get :update, :apply => 'Uncomplete', :items => @list.items.map{|i| i.id}, :list_id => @list.id
        @list.reload.items.each{|i| i.should be_active }
      end
    end

    it "should return a status code of 200" do
      get :update, :apply => 'Uncomplete', :items => @list.items.map{|i| i.id}, :list_id => @list.id
      response.should be_success      
    end
  end
end

