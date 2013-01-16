module Listable
  module LookupByIdOrUuid
    class InvalidId < StandardError ; end

    def lookup_by_id_or_uuid(id_or_uuid)
      case id_or_uuid.to_s
          
        when Listable::Constants::UUID_RE
          self.find_by_uuid(id_or_uuid)

        when /^\d+$/
          self.find_by_id(id_or_uuid)

        else
          raise InvalidId, "Input '#{id_or_uuid}' is not a valid id, nor is it a valid uuid."  
      end
    end
  end
end