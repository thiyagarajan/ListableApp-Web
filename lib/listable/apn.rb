module Listable
  
  # Apple push notification message.
  class Apn
    include ::ActionView::Helpers::TextHelper
    extend ::ActionView::Helpers::TextHelper
    include ActionView::Helpers::DateHelper
    
    attr_reader :message
    
    def self.send_notifications
      notifications = []
      while n = QUEUE.get(APN_QUEUE)
        notifications << n  
      end

      unless notifications.empty?
        Listable::ApnConnection.new(:gateway).open do |conn, _|
          notifications.each do |n|
            Rails.logger.info "#{DateTime.now} Writing APN notification: #{n.inspect}"
            conn.write(n)
          end
        end               
      end
    end
    
    # Enqueue a message suitable for being sent from the blip passed to us
    def initialize(blip, enqueue = false)
      @blip = blip

      @message = {
        :aps => {
          :alert => truncate(message_for(blip), :length => 150),
          :badge => blip.destination_user.update_count
        }
      }
              
      if enqueue
        blip.destination_user.increment!(:update_count)
        @message[:aps][:badge] = blip.destination_user.update_count # updated count
        QUEUE.set(APN_QUEUE, message_to_json(@message))
      end
      
    end
    
    def message_to_json(message)
      json = message.to_json
      msg = "\0\0 #{@blip.destination_user.device_token_hex}\0#{json.length.chr}#{json}"
      raise RuntimeError, "Message too big for APN" if msg.size.to_i > 256
      RAILS_DEFAULT_LOGGER.info("Putting msg in q: #{msg}")
      msg
    end
    
    
    def message_for(blip)
      past_term = case blip.action_type.action_type_id
      when 1
        "added"
      when 2
        "completed"
      when 3
        "uncompleted"
      when 4
        "added"
      end

      entity_description = case blip.action_type.action_type_id
      when 1, 2, 3
        truncate(blip.modified_item.name, :length => 100)
      when 4
        blip.modified_item.login
      end

      "'#{entity_description}' was #{past_term} by #{blip.originating_user.login} on #{blip.modified_item.list.name}"
    end
    
  end
end