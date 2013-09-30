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
        @name       = name
        @properties = properties.dup

        merge! properties if Hash === properties
      end # method initialize

      # @return [Symbol] The name of the concern or relation.
      attr_reader :name

      # @return [Hash] The unmodified properties hash that was passed into the
      #   constructor.
      attr_reader :properties

      # @overload characterize name, properties, type = Metadata
      #   Creates a metadata instance for a subgroup of the metadata, such as a
      #   generated relation or for an optional parameter.
      # 
      #   @param [Symbol] name The name of the relation. Must be unique for the
      #     base type within the sleeping_king_studios namespace.
      #   @param [Hash] properties The options for the relation.
      #   @param [Class] type The type of the generated metadata.
      # 
      #   @return [Metadata] The generated metadata.
      def characterize name, properties, type = nil
        type ||= Mongoid::SleepingKingStudios::Concern::Metadata
        type.new name, properties
      end # method characterize

      # The key used to store the metadata inside the class's ::relations
      # attribute. By default, adds the prefix 'sleeping_king_studios::' to the
      # name, but can be set via the properties hash.
      # 
      # @return [String] The key used to store the metadata.
      def relation_key
        self[:relation_key] || name.to_s
      end # method relation_key

      # @return [Boolean] True if a custom relation key is defined, otherwise
      #   false.
      def relation_key?
        !!self[:relation_key]
      end # method relation_key?
    end # class
  end # module
end # module
