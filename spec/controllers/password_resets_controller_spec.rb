require 'spec_helper'

describe PasswordResetsController do

  describe "#create" do
    describe "with a valid email" do
      before do
        @user = Factory(:user)
        get :create, :email => @user.email
      end
      
      it "should work" do
        response.should redirect_to(root_url)
      end
    end
  end
end
