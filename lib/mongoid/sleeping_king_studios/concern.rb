# lib/mongoid/sleeping_king_studios/concern.rb

require 'mongoid/sleeping_king_studios'
require 'mongoid/sleeping_king_studios/concern/metadata'

module Mongoid::SleepingKingStudios
  # Base class for concerns with shared behavior, such as creating metadata
  # objects from an options hash and storing that metadata in the Document
  # class's ::relations attribute.
  # 
  # @since 0.6.0
  module Concern
    # Mixin to add a #sleeping_king_studios property to the #relations hash.
    # 
    # @example
    #   base.relations.extend Relations
    module Relations
      # Stores relations from Mongoid::SleepingKingStudios in a nested hash
      # to avoid automatic behaviour on the base #relations hash.
      attr_accessor :sleeping_king_studios
    end # module

    # Creates a metadata instance for the relation.
    # 
    # @param [Symbol] name The name of the relation. Must be unique for the
    #   base type within the sleeping_king_studios namespace.
    # @param [Hash] options The options for the relation.
    # 
    # @return [Metadata] The generated metadata.
    def characterize name, options
      Metadata.new name, options
    end # method characterize

    # Stores the metadata in the class's relations object. To avoid automatic
    # Mongoid behavior on relations, adds a #sleeping_king_studios accessor to
    # the relations hash by mixing in the Relations module. Then, saves the
    # metadata using the metadata#relation_key as the key.
    # 
    # @param [Class] base The base class into which the concern is mixed in.
    # @param [Symbol] name The name of the relation. Must be unique for the
    #   base type within the sleeping_king_studios namespace.
    # @param [Metadata] metadata The metadata to be stored.
    def relate base, name, metadata
      unless base.relations.respond_to?(:sleeping_king_studios)
        base.relations.extend Relations 
        base.relations.sleeping_king_studios = {}
      end # unless
      base.relations.sleeping_king_studios.update metadata.relation_key => metadata
    end # method relate

    # Returns a list of options that are valid for this concern.
    # 
    # @return [Array<Symbol>] The list of valid options.
    def valid_options
      %i(

      ) # end array
    end # method valid_options

    # Evaluates the provided options and raises an error if any of the options
    # are invalid, based on the list from #valid_options.
    # 
    # @param [Symbol] name The name of the relation.
    # @param [Hash] options The options for the relation.
    # 
    # @raise [Mongoid::Errors::InvalidOptions] If any of the options provided
    #   are invalid.
    def validate_options name, options
      options.keys.each do |key|
        if !valid_options.include?(key)
          raise Mongoid::Errors::InvalidOptions.new(
            name,
            key,
            valid_options
          ) # end InvalidOptions
        end # if
      end # each
    end # method validate_options
  end # class
end # module
