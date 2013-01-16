module Listable
  module Uuid
    def self.generate
      ActiveRecord::Base.connection.execute("SELECT UUID()").fetch_row[0]
    end
  end
end