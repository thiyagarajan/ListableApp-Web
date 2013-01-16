require 'spec_helper'

describe Listable::ActionType do
  describe "initialization" do
    it "should have an action type name when initialized with an ID" do
      at = Listable::ActionType.new(:action_type_id => 1)
      at.name.should == "Add item"
    end
  end
end
