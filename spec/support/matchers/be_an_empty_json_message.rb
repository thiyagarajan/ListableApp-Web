module CustomJsonMessageMatcher
  
  class BeAnEmptyJsonMessage
    EMPTY_JSON_MSG = { :message => '' } unless defined?(EMPTY_JSON_MSG)
    
    def initialize(expected)
      @expected = expected
    end
  
    def matches?(target)
      @target = target
      
      parsed = JSON.parse(target)
      parsed['message'] == '' && parsed.keys.size == 1
    end
  
    def failure_message_for_should
      "expected #{@target.inspect} to have an empty JSON message"
    end
  
    def failure_message_for_should_not
      "expected #{@target.inspect} not to be an empty JSON message"
    end
  end
  
  def be_an_empty_json_message
    BeAnEmptyJsonMessage.new(@expected)
  end
end

Spec::Runner.configure do |config|
  config.include(CustomJsonMessageMatcher)
end
