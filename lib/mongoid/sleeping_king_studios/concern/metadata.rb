# lib/mongoid/sleeping_king_studios/concern/metadata.rb

require 'mongoid/sleeping_king_studios'
require 'mongoid/sleeping_king_studios/concern'

module Mongoid::SleepingKingStudios
  module Concern
    # Stores information about a given concern or relation. By default, stored
    # in the Document class's ::relations attribute. Concerns may subclass
    # Metadata to add further keys and/or functionality.
    # 
    # @since 0.6.0
    class Metadata < Hash
      # @param [Symbol, String] name The name of the concern or relation.
      # @param [Hash] properties The properties of the concern or relation.
      def initialize name, properties = {}
        merge! :name => name.to_s.intern
        merge! properties if Hash === properties
      end # method initialize

      # @return [Symbol] The name of the concern or relation.
      def name
        self[:name]
      end # method name

      # The key used to store the metadata inside the class's ::relations
      # attribute. By default, adds the prefix 'sleeping_king_studios::' to the
      # name, but can be set via the properties hash.
      # 
      # @return [String] The key used to store the metadata.
      def relation_key
        self[:relation_key] || "sleeping_king_studios::#{name}"
      end # method relation_key

      # @return [Boolean] True if a custom relation key is defined, otherwise
      #   false.
      def relation_key?
        !!self[:relation_key]
      end # method relation_key?
    end # class
  end # module
end # module
