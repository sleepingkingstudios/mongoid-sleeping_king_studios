# lib/mongoid/sleeping_king_studios/has_tree/metadata.rb

require 'mongoid/sleeping_king_studios/concern/metadata'
require 'mongoid/sleeping_king_studios/has_tree/cache_ancestry/metadata'
require 'mongoid/sleeping_king_studios/has_tree/children/metadata'
require 'mongoid/sleeping_king_studios/has_tree/parent/metadata'

module Mongoid::SleepingKingStudios
  module HasTree
    # Stores information about a HasTree concern.
    class Metadata < Mongoid::SleepingKingStudios::Concern::Metadata
      # @param [Symbol, String] name The name of the concern or relation.
      # @param [Hash] properties The properties of the concern or relation.
      def initialize name, properties = {}
        super

        self[:parent]   = characterize :parent,   properties.fetch(:parent,   {}), HasTree::Parent::Metadata
        self[:children] = characterize :children, properties.fetch(:children, {}), HasTree::Children::Metadata

        if properties.fetch(:cache_ancestry, false)
          properties[:cache_ancestry] = {} unless Hash === properties[:cache_ancestry]
          properties[:cache_ancestry][:children_name] = children.relation_name
          properties[:cache_ancestry][:parent_name]   = parent.relation_name
          
          self[:cache_ancestry] = characterize :cache_ancestry, properties[:cache_ancestry], HasTree::CacheAncestry::Metadata
        end # unless
      end # constructor

      # The metadata associated with the :cache_ancestry option.
      # 
      # @return [Metadata] The :cache_ancestry metadata.
      def cache_ancestry
        self[:cache_ancestry]
      end # method cache_ancestry

      # @return [Boolean] True if the :cache_ancestry option is selected;
      #   otherwise false.
      def cache_ancestry?
        !!self[:cache_ancestry]
      end # method cache_ancestry?

      # The metadata associated with the #children relation.
      # 
      # @return [Metadata] The children metadata.
      def children
        self[:children]
      end # method children

      # The metadata associated with the #parent relation.
      # 
      # @return [Metadata] The parent metadata.
      def parent
        self[:parent]
      end # method parent
    end # class
  end # module
end # module
