require 'spec_helper'

describe Listable::LookupByIdOrUuid do
  it "should raise Listable::LookupByIdOrUuid::InvalidId exception if the input is not a valid id or uuid" do
    lambda {
      List.lookup_by_id_or_uuid('foo')
    }.should raise_error(Listable::LookupByIdOrUuid::InvalidId )
  end

  it "should find a record by its id" do
    list = Factory(:list)
    List.lookup_by_id_or_uuid(list.id).should == list
  end

  it "should find a record by its uuid" do
    list = Factory(:list)
    List.lookup_by_id_or_uuid(list.uuid).should == list    
  end

  it "should return nil if a record is not found by id" do
    list = Factory(:list)
    invalid_id = list.id
    list.destroy

    List.lookup_by_id_or_uuid(invalid_id).should be_nil
  end

  it "should return nil if a record is not found by uuid" do
    list = Factory(:list)
    invalid_uuid = list.uuid
    list.destroy

    List.lookup_by_id_or_uuid(invalid_uuid).should be_nil
  end
end