shared_examples_for "all json actions" do
  it "should be valid json" do
    response.body.should be_valid_json
  end
  
  it "should have a json content type" do
    response.content_type.should == "application/json"
  end
end