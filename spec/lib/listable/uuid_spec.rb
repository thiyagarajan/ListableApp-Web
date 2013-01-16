require 'spec_helper'

describe Listable::Uuid do
  describe "#generate" do
    it "should return a UUID in the correct form" do
      Listable::Uuid.generate.should =~ /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/
    end
  end
end