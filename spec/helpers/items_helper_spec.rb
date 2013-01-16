require 'spec_helper'

describe ItemsHelper do
  describe "#unsubscribe_text_for" do
    it "should return one confirmation message when there are other users associated with the list" do
      list = Factory(:list)
      list.users << Factory(:user)
      list.users << Factory(:user)

      helper.unsubscribe_text_for(list).should == "Are you sure you wish to unsubscribe from this list?  You will no longer be able to access its contents, nor will you receive updates about it after unsubscribing."
    end

    it "should display a different confirmation message when the user is the last one on the list" do
      list = Factory(:list)
      list.users << Factory(:user)

      helper.unsubscribe_text_for(list).should == "Are you sure you wish to unsubscribe from this list?  You are the only user subscribed, so it will be deleted once you unsubscribe."
    end
  end
end