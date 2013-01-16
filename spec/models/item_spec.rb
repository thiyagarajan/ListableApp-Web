require 'spec_helper'

describe Item do
  before do
    @owner = Factory(:user)
    @list = Factory(:list, :creator => @owner)
  end

  describe "setting the uuid" do
    it "should have a uuid after creation" do
      Factory(:item, :list => Factory(:list)).uuid.should =~ /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/
    end
  end

  describe "with_name_like named scope" do
    it "should return only items matching the name" do
      myitem = Factory(:item, :list => @list, :name => 'pizza')
      @list.items.with_name_like('pizza').all.should == [ myitem ]
    end
  end

  describe "sorted alphabetically named scope" do
    it "should return items with names in alphabetical order" do
      list = Factory(:list)
      item2 = Factory(:item, :list => list, :name => 'Beaver')
      item1 = Factory(:item, :list => list, :name => 'Animal')
      list.items.sorted_alphabetically.should == [item1, item2]
    end
  end

  it "should create a new instance given valid attributes" do
    item = Factory(:item, :list => @list)
    item.save!
  end
  
  it "should not be valid with a position of 0" do
    item = Factory(:item, :list => @list)
    item.position = 0
    item.save
    item.should_not be_valid
    item.errors.full_messages.first.should =~ /must not be 0/
  end  

  describe "validation for length of item name" do
    it "should be valid if the name is 1024 chars" do
      item = Factory(:item, :list => @list)

      item.name = 'a' * 1024
      item.should be_valid
    end
    
    it "should not be valid if the name is > 1024 chars" do
      item = Factory(:item, :list => @list)

      item.name = 'a' * 1025
      item.should_not be_valid
    end
  end
  
  describe "when the scope changes" do
    before do
      @lx = Factory(:list)
      @it1 = Factory(:item, :list => @lx, :position => 1, :name => 'item 1')
      @it2 = Factory(:item, :list => @lx, :position => 3, :name => 'item 2')
      @it3 = Factory(:item, :list => @lx, :position => 4, :name => 'item 3')
      @it4 = Factory(:item, :list => @lx, :position => 5, :name => 'item 4')
    end
    
    it "should pack the original scope of the item so that it doesn't have any gaps" do
      @it3.completed = true
      @it3.save
      
      @it1.reload.position.should == 1
      @it2.reload.position.should == 2
      @it4.reload.position.should == 3
    end
  end
    
  it "should create a blip after creation" do
    lambda {
      Factory(:item, :list => @list)
    }.should change(Blip, :count).by(1)
  end
  
  describe "creating completed_changed blips" do
    it "should create a blip with action type 2 if the item is completed" do
      item = Factory(:item, :list => @list)

      item.completed = false
      item.save
      
      lambda {
        item.completed = true
        item.save
      }.should change(Blip, :count).by(1)
      
      Blip.last.action_type_id.should == 2
    end
    
    it "should create a blip with action type 3 if the item is uncompleted" do
      item = Factory(:item, :list => @list)

      item.completed = true ; item.save
      
      lambda {
        item.completed = false ; item.save
      }.should change(Blip, :count).by(1)
      
      Blip.last.action_type_id.should == 3
    end
  end

  describe "#active?" do
    it "should return true if not completed" do
      item = Factory(:item, :list => @list)

      item.update_attributes(:completed => false)
      item.reload

      item.should be_active
    end

    it "should return false if completed" do
      item = Factory(:item, :list => @list)

      item.update_attributes(:completed => true)
      item.reload

      item.should_not be_active
    end
  end
end
