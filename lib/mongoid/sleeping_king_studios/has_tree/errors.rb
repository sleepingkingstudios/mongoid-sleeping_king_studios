# lib/mongoid/sleeping_king_studios/has_tree/errors.rb

require 'mongoid/sleeping_king_studios/error'

module Mongoid::SleepingKingStudios
  module HasTree
    module Errors
      class MissingAncestor < Mongoid::SleepingKingStudios::Error
        def initialize ancestor_id
          message = Array === ancestor_id ?
            'ancestors with ids' :
            'ancestor with id'
          super "unable to find #{message} #{ancestor_id.inspect}"
        end # constructor
      end # class

      class UnexpectedAncestor < Mongoid::SleepingKingStudios::Error
        def initialize expected_id, received_id
          super "expected ancestor with id #{expected_id.inspect}, but received id #{received_id.inspect}"
        end # constructor
      end # class
    end # module Errors
  end # module
end # module
