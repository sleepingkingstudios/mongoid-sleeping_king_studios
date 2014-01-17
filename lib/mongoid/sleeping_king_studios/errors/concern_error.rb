# lib/mongoid/sleeping_king_studios/errors/concern_error.rb

require 'mongoid/sleeping_king_studios/errors/base_error'

module Mongoid::SleepingKingStudios::Errors
  class ConcernError < Mongoid::SleepingKingStudios::Errors::BaseError
    def initialize base, metadata, problem = nil, **options
      problem ||= "An error occurred with the #{metadata.name.to_s.camelize}" +
        " concern for class #{base}."

      super(problem, **options)

      @base     = base
      @metadata = metadata
    end # constructor

    attr_accessor :base, :metadata
  end # class
end # module
