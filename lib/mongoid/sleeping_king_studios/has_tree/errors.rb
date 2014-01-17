# lib/mongoid/sleeping_king_studios/has_tree/errors.rb

require 'mongoid/sleeping_king_studios/errors/base_error'

module Mongoid::SleepingKingStudios
  module HasTree
    module Errors
      class UnexpectedAncestor < Mongoid::SleepingKingStudios::Errors::BaseError
        def initialize relation_name, expected_id, received_id
          message = "expected #{relation_name.to_s.singularize} with id"
          super "#{message} #{expected_id.inspect}, but received id #{received_id.inspect}"
        end # constructor
      end # class
    end # module Errors
  end # module
end # module
