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
    module Relations
      attr_accessor :sleeping_king_studios
    end # module

    def characterize name, options
      Metadata.new name, options
    end # method characterize

    def relate base, name, metadata
      base.relations.extend Relations
      base.relations.sleeping_king_studios ||= {}
      base.relations.sleeping_king_studios.update metadata.relation_key => metadata
    end # method relate

    def valid_options
      %i(

      ) # end array
    end # method valid_options

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
