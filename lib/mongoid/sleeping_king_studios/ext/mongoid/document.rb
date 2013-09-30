# lib/mongoid/sleeping_king_studios/ext/mongoid/document.rb

require 'mongoid'

module Mongoid
  module Document
    module ClassMethods
      # Metadata for the relations and concerns on the document class in the
      # Mongoid::SleepingKingStudios namespace.
      def relations_sleeping_king_studios
        @relations_sleeping_king_studios ||= {}
      end # class method relations_sleeping_king_studios
    end # module
  end # module
end # module
