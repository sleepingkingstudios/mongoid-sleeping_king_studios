# lib/mongoid/sleeping_king_studios/has_tree/cache_ancestry/metadata.rb

require 'mongoid/sleeping_king_studios/concern/metadata'

module Mongoid::SleepingKingStudios
  module HasTree
    module CacheAncestry
      # Stores information about a HasTree::CacheAncestry concern.
      class Metadata < Mongoid::SleepingKingStudios::Concern::Metadata
        # The name of the children relation for the tree.
        # 
        # @return [Symbol] The relation name.
        def children_name
          self[:children_name] || :children
        end # method parent_name

        # @return [Boolean] True if a custom children relation name is set;
        #   otherwise false.
        def children_name?
          !!self[:children_name]
        end # method children_name?

        # The name of the field used to store ancestor references. If no
        # foreign key is set, uses the relation name and the field name to
        # generate a key.
        # 
        # @return [Symbol] The field name.
        def foreign_key
          self[:foreign_key] || :"#{relation_name.to_s.singularize}_ids"
        end # method foreign_key

        # The name of the field used to store the tree's parent relation.
        # 
        # @return [Symbol] The method name.
        def parent_foreign_key
          :"#{parent_name}_id"
        end # method parent_foreign_key

        # The writer for the tree's parent relation id.
        # 
        # @return [Symbol] The method name.
        def parent_foreign_key_writer
          :"#{parent_name}_id="
        end # method parent_foreign_key_writer

        # The name of the parent relation for the tree.
        # 
        # @return [Symbol] The relation name.
        def parent_name
          self[:parent_name] || :parent
        end # method parent_name

        # @return [Boolean] True if a custom children relation name is set;
        #   otherwise false.
        def parent_name?
          !!self[:parent_name]
        end # method parent_name?

        # The writer for the tree's parent relation.
        # 
        # @return [Symbol] The method name.
        def parent_writer
          :"#{parent_name}="
        end # method parent_name

        # The name of the tree's ancestors method. If no relation name is set,
        # defaults to :ancestors.
        # 
        # @return [Symbol] The relation name.
        def relation_name
          fetch(:relation_name, :ancestors)
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
