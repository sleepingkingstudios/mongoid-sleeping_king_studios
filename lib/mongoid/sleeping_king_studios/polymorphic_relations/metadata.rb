# lib/mongoid/sleeping_king_studios/polymorphic_relations/metadata.rb

require 'mongoid/sleeping_king_studios/concern/metadata'

module Mongoid::SleepingKingStudios
  module PolymorphicRelations
    # Stores information about a PolymorphicRelations concern.
    class Metadata < Mongoid::SleepingKingStudios::Concern::Metadata
      class << self
        def default_field_name child_relation, base_relation
          :"polymorphic_relation_#{base_relation}_as_#{child_relation}"
        end # class method default_field_name
      end # class << self
    end # class
  end # module
end # module
