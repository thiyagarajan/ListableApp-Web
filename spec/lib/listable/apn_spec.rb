require 'spec_helper'

describe Listable::Apn do
  describe "initialization" do
    before do
      @destination_user = Factory(:user, :device_token => 'fofofofofo')
      @blip = Factory(:blip, :destination_user => @destination_user,:action_type => Listable::ActionType.new(2), :modified_item => Factory(:item, :list => Factory(:list)), :originating_user => Factory(:user), :list => Factory(:list))
      @apn = Listable::Apn.new(@blip, true)
    end
  
    it 'should make an apn with a message' do
      @apn.message[:aps][:alert] =~ /completed by/
    end
  
    it "should enqueue the item" do
      QUEUE.expects(:set)
      Listable::Apn.new(@blip, true)
    end
  
    it "should increment the update count on the user" do
      lambda {
        Listable::Apn.new(@blip, true)
      }.should change(@destination_user, :update_count).by(1)
    end    
  end

  describe "##send_notifications" do
    it "should send the available notifications" do
      QUEUE.stubs(:get).with(APN_QUEUE).returns('foo', nil)

      connection = mock('connection')
      connection.expects(:write).with('foo')

      apn_connection = mock('apn_connection')
      apn_connection.expects(:open).once.yields(connection, nil)
      
      Listable::ApnConnection.expects(:new).with(:gateway).once.returns(apn_connection)
      Listable::Apn.send_notifications
    end

    it "should call open once even if multiple messages exist in queue" do
      QUEUE.stubs(:get).with(APN_QUEUE).returns('foo', 'bar', nil)

      connection = mock('connection')
      connection.expects(:write).twice

      apn_connection = mock('apn_connection')
      apn_connection.expects(:open).once.yields(connection, nil)

      Listable::ApnConnection.expects(:new).with(:gateway).once.returns(apn_connection)
      Listable::Apn.send_notifications
    end

    it "should call the write on the connection once for each message in the queue" do
      QUEUE.stubs(:get).with(APN_QUEUE).returns('foo', 'bar', nil)

      connection = mock('connection')
      connection.expects(:write).with('foo').once
      connection.expects(:write).with('bar').once

      apn_connection = mock('apn_connection')
      apn_connection.expects(:open).once.yields(connection, nil)

      Listable::ApnConnection.expects(:new).with(:gateway).once.returns(apn_connection)
      Listable::Apn.send_notifications
    end

    it "should not open an apn connection if there are no notifications" do
      QUEUE.stubs(:get).with(APN_QUEUE).returns(nil)
      
      Listable::ApnConnection.expects(:new).never

      Listable::Apn.send_notifications
    end
  end
end
