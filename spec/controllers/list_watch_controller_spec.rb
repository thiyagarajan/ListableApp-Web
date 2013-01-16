require 'spec_helper'

describe ListWatchController do
  describe "#update" do
    before do
      @list = Factory(:list)
      @user = Factory(:user)
      
      login_as(@user)
      
      @user.lists << @list

      # Need the user list link to allow the user to watch or unwatch.
      @link = UserListLink.first(:conditions => { :user_id => @user.id, :list_id => @list.id})
    end
    
    it "should toggle list watch status from false to true" do
      lambda {
        get :update, :id => @link.id
        @link.reload
      }.should change(@link, :watching?).from(true).to(false)
    end
  end
end
