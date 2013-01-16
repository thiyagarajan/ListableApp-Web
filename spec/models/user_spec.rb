require 'spec_helper'

describe User do
  before do
    @user = Factory(:user)
  end
  
  it "should produce a valid user from the factory" do
    @user.should be_valid
  end
    
  # An email must be a valid username for stuff in Collaborators controller to work
  describe "username validations" do
    it "should not be valid with a space in the username" do
      @user.login = "hey there"
      @user.should_not be_valid
    end
    
    it "should not be valid with a '@'" do
      @user.login = "hey@there"
      @user.should be_valid
    end
    
    it "should not be valid with a '#'" do
      @user.login = "hey#there"
      @user.should_not be_valid
    end
    
    it "should not be valid if it is less than 3 characters" do
      @user.login = "he"
      @user.should_not be_valid
    end
    
    it "should not be valid if it is > 100 characters" do
      @user.login = "h" * 101
      @user.should_not be_valid
    end
    
    it "should not be valid if it is nil" do
      @user.login = nil
      @user.should_not be_valid
    end
  end
    
end
