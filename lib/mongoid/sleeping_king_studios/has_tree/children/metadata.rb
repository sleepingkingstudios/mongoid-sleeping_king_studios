# lib/mongoid/sleeping_king_studios/has_tree/children/metadata.rb

require 'mongoid/sleeping_king_studios/concern/metadata'

module Mongoid::SleepingKingStudios
  module HasTree
    module Children
      # Stores information about a HasTree concern's children relation.
      class Metadata < Mongoid::SleepingKingStudios::Concern::Metadata
        # The name of the tree's parent relation. If no relation name is set,
        # defaults to :parent.
        # 
        # @return [Symbol] The relation name.
        def inverse_of
          fetch(:inverse_of, :parent)
        end # method inverse_of

        # @return [Boolean] True if a custom inverse relation name is set;
        #   otherwise false.
        def inverse_of?
          !!self[:inverse_of]
        end # method inverse_of?

        # The name of the tree's children relation. If no relation name is set,
        # defaults to :children.
        # 
        # @return [Symbol] The relation name.
        def relation_name
          fetch(:relation_name, :children)
        end # method relation_name

        # @return [Boolean] True if a custom relation name is set; otherwise
        #   false.
        def relation_name?
          !!self[:relation_name]
        end # method relation_name?
      end # class
    end # module
  end # module
end # module
