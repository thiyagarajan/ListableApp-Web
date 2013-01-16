module Listable
  class ApnFeedback
    
    def self.process_devices
      Listable::ApnConnection.new(:feedback).open do |conn, sock|
        while line = conn.read(38)   # Read lines from the socket
          line.strip!
          
          feedback = line.unpack('NnH*')
          
          token = feedback[2]
          puts "Got token in feedback #{token}, feedback time was #{Time.at(feedback[0])}"
          
          user = User.find_by_device_token(token)

          if user && user.device_registered_at.to_f < Time.at(feedback[0]).to_f
            puts "Removing device token for #{user.email}"
            user.update_attributes(:device_token => nil)
          end
        end        
      end      
    end
  end
end