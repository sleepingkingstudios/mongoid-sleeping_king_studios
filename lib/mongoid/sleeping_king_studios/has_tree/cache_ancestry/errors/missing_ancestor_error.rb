# lib/mongoid/sleeping_king_studios/has_tree/cache_ancestry/errors/missing_ancestor_error.rb

require 'mongoid/sleeping_king_studios/errors/concern_error'

require 'mongoid/sleeping_king_studios/has_tree/cache_ancestry/errors'

module Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Errors
  class MissingAncestorError < Mongoid::SleepingKingStudios::Errors::ConcernError
    def initialize base, metadata, expected, **options
      expected = [expected].flatten
      problem  = "Ancestor not found for #{metadata.foreign_key} " +
        "#{expected.inspect}."

      super(base, metadata, problem, **options)

      @expected = expected
    end # method initialize

    attr_accessor :expected
  end # class
end # module
