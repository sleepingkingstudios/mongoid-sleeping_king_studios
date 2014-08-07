# lib/mongoid/sleeping_king_studios/polymorphic_relations.rb

require 'mongoid/sleeping_king_studios/concern'
require 'mongoid/sleeping_king_studios/polymorphic_relations/metadata'

module Mongoid::SleepingKingStudios
  # @since 0.8.0
  module PolymorphicRelations
    extend ActiveSupport::Concern
    extend Mongoid::SleepingKingStudios::Concern

    def self.apply base, child_relation, base_relation, **options
      validate_options nil, options

      name = Metadata.default_field_name(child_relation, base_relation)
      meta = characterize name, options, Metadata

      relate base, name, meta
    end # module method apply

    # Returns a list of options that are valid for this concern.
    # 
    # @return [Array<Symbol>] The list of valid options.
    # 
    # @since 0.6.0
    def self.valid_options
      super + %i(
        class_name
      ) # end array
    end # module method valid options

    # Class methods added to the base class via #extend.
    module ClassMethods
      def polymorphic_relation child_relation, base_relation, **options
        concern = Mongoid::SleepingKingStudios::PolymorphicRelations
        concern.apply self, child_relation, base_relation, options
      end # class method polymorphic_relation
    end # module ClassMethods
  end # module
end # module
