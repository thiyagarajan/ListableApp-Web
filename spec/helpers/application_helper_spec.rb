require 'spec_helper'

describe ApplicationHelper do

  describe "#render_blip" do
    before do
      @b = Factory(:blip, :list => Factory(:list))
      login_as(Factory(:user))
    end
    
    it "should not raise an error" do
      helper.render_blip(@b)
    end
  end

  describe "#page_header_links" do
    it "should render a link to log in when the user is logged out" do
      helper.stubs(:current_user).returns(nil)
      helper.page_header_links.should =~ /Log in/
    end

    it "should render a link to log out when the user is logged in" do
      # TODO - improve the stubbing for AuthLogic, or switch to devise/warden.
      helper.stubs(:current_user).returns(Factory(:user))
      helper.page_header_links.should =~ /Log out/
    end
  end

  describe "#gravatar_url_for" do
    it "should return a url containing 'gravatar'" do
      helper.gravatar_url_for('justin@phq.org').should =~ /gravatar.com/
    end

    it "should return the downcased email MD5" do
      email = 'JUSTIN@PHQ.ORG'
      helper.gravatar_url_for(email).should =~ /#{Digest::MD5.hexdigest(email.downcase)}/ 
    end
  end

end
