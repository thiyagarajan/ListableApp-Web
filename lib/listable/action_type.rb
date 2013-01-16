module Listable
  
  # Describes an action type for blips.
  class ActionType
    ALL_TYPES = {
      1 => "Add item",
      2 => "Complete item",
      3 => "Uncomplete item",
      4 => "Add collaborator"
    }
    
    attr_reader :action_type_id, :name
        
    # Allows init from Integer for use in composed_of, as well as manually setting the
    # :action_type_id as an option, in which case it sets name based on entry in ALL_TYPES.
    def initialize(*args)
      opts = args.extract_options!
      
      opts[:action_type_id] = args.first if args.first.is_a?(Integer)
      
      if opts[:action_type_id]
        @action_type_id = opts[:action_type_id]
        @name           = ALL_TYPES[opts[:action_type_id]]
      end
    end    
    
    def past_term
      case action_type_id
      when 1
        "added"
      when 2
        "completed"
      when 3
        "uncompleted"
      when 4
        "added"
      end
    end
    
  end
  
end