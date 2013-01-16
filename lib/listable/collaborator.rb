module Listable
  class Collaborator
    attr_accessor :email, :list, :creator, :login
    attr_reader :errors
    
    def initialize(*params)
      options = params.extract_options!

      @errors = ActiveRecord::Errors.new([])
      
      @email = options[:email] || ""
      @login = options[:login] || ""
    end
    
  end
end