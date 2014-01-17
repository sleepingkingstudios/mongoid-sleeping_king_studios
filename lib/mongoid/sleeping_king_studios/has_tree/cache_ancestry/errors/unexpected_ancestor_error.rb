# lib/mongoid/sleeping_king_studios/has_tree/cache_ancestry/errors/unexpected_ancestor_error.rb

require 'mongoid/sleeping_king_studios/errors/concern_error'

require 'mongoid/sleeping_king_studios/has_tree/cache_ancestry/errors'

module Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Errors
  class UnexpectedAncestorError < Mongoid::SleepingKingStudios::Errors::ConcernError
    def initialize base, metadata, expected, received, **options
      expected  = [expected].flatten
      received  = [received].flatten
      problem   = "Unexpected ancestor(s) found for" +
        " #{metadata.foreign_key}." +
        "\n" +
        "\n  Expected:" +
        "\n    #{expected.inspect}" +
        "\n  Received:" +
        "\n    #{received.inspect}"

      super(base, metadata, problem, **options)

      @expected = expected
      @received = received
    end # method initialize

    attr_accessor :expected, :received
  end # class
end # module
