require 'spec_helper'

describe HomeController do
  integrate_views
  
  it "should render successfully" do
    get :index
    response.should be_success
  end
end
