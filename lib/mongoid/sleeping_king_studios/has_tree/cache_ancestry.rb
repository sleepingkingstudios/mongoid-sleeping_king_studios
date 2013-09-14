# lib/mongoid/sleeping_king_studios/has_tree/cache_ancestry.rb

require 'mongoid/sleeping_king_studios'
require 'mongoid/sleeping_king_studios/has_tree/errors'

module Mongoid::SleepingKingStudios
  module HasTree
    # Adds #ancestors and #descendents methods for accessing ancestors and
    # subtrees with a single read operation. Do not include this module
    # directly; rather, add a :cache_ancestry => true options to the call
    # to ::has_tree.
    # 
    # @example Setting up a tree with ancestry cache:
    #   class SluggableDocument
    #     include Mongoid::Document
    #     include Mongoid::SleepingKingStudios::Tree
    # 
    #     has_tree :cache_ancestry => true
    #   end # class
    # 
    # @since 0.5.0
    module CacheAncestry
      extend ActiveSupport::Concern

      # Get the valid options allowed with this concern.
      # 
      # @return [ Array<Symbol> ] The valid options.
      #
      # @since 0.5.1
      def self.valid_options
        %i(
          relation_name
        ) # end Array
      end # class method valid_options

      # @!attribute [r] ancestor_ids
      #   Stores the ids of the object's ancestors, starting from the root
      #   object of the current subtree to the object's current parent. If
      #   the object has no parent, returns an empty array.
      # 
      #   @return [Array] The ancestors' ids.
      # 
      #   @since 0.5.0

      # Class methods added to the base class via #extend.
      module ClassMethods
        # @overload cache_ancestry(options = {})
        #   Adds the :ancestry_id field, the #ancestors and #descendents
        #   scopes, and redefines #parent_id= to update the :ancestry_id
        #   field on the object and its descendents.
        # 
        #   Do not call this method directly; rather, add
        #   :cache_ancestry => true or :cache_ancestry => { **options } to the
        #   call to ::has_tree.
        # 
        #   @param [Hash] options The options for the cache_ancestry concern.
        # 
        #   @option options [Hash] :relation_name ('ancestors') The name of the
        #     generated relation for the array of parents identifiers. If no
        #     foreign key is defined, sets the foreign key to the singularized
        #     relation name plus a suffix for the chosen identifier, e.g. the
        #     default relation name 'ancestors' becomes a field ancestor_ids.
        # 
        #   @see Mongoid::SleepingKingStudios::HasTree::ClassMethods.has_tree
        def cache_ancestry **options
          parent_name   = options[:children][:inverse_of]
          children_name = options[:parent][:inverse_of]
          
          opts = Hash === options[:cache_ancestry] ?
            options[:cache_ancestry] :
            {}

          relation_name = opts[:relation_name] || 'ancestors'
          foreign_key   = opts[:foreign_key]   || :"#{relation_name.singularize}_ids"

          binding.pry if $BINDINGi

          field foreign_key, :type => Array, :default => []

          alias_method :"set_parent_id", :"#{parent_name}_id="
          private :set_parent_id

          class_eval <<-RUBY
            def #{parent_name}_id= value
              old_ancestor_ids = #{foreign_key}.dup

              set_parent_id value
              new_ancestor_ids = parent ? parent.#{foreign_key} + [parent.id] : []

              descendents.each do |descendent|
                ary = descendent.#{foreign_key}.dup
                ary[0..old_ancestor_ids.count] = new_ancestor_ids + [id]
                descendent.update_attributes :#{foreign_key} => ary
              end # each
              
              self.send :#{foreign_key}=, new_ancestor_ids
            end # method #{parent_name}_id=

            def #{relation_name}
              self.class.find(#{foreign_key})
            rescue Mongoid::Errors::DocumentNotFound, Mongoid::Errors::InvalidFind
              raise Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor.new "#{relation_name}", #{foreign_key}
            end # method ancestors

            def descendents
              criteria = self.class.all

              #{foreign_key}.each_with_index do |ancestor_id, index|
                criteria = criteria.where(:"#{foreign_key}.\#{index}" => ancestor_id)
              end # each

              criteria.where(:"#{foreign_key}.\#{#{foreign_key}.count}" => id)
            end # scope descendents

            def rebuild_ancestry!
              ary, object = [], self
              while object.parent
                ary.unshift object.parent.id
                object = object.parent
              end # while
              self.send :#{foreign_key}=, ary
            rescue Mongoid::Errors::DocumentNotFound
              raise Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor.new "#{relation_name}", object.parent_id
            end # method rebuild_ancestry!

            def validate_ancestry!
              return if #{foreign_key}.empty?

              ancestors = []
              #{foreign_key}.each_with_index do |ancestor_id, index|
                begin
                  ancestor = self.class.find(ancestor_id)
                  ancestors << ancestor

                  if index > 0 && ancestor.parent_id != #{foreign_key}[index - 1]
                    # If the ancestor's parent is not the same as the previous
                    # ancestor.
                    raise Mongoid::SleepingKingStudios::HasTree::Errors::UnexpectedAncestor.new "#{relation_name}", ancestor.parent_id, #{foreign_key}[index - 1]
                  end # if
                rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
                  # If the ancestor id is nil, or the ancestor does not exist.
                  raise Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor.new "#{relation_name}", ancestor_id
                end # begin-rescue
              end # each
            end # method validate_ancestry!
          RUBY
        end # class method cache_ancestry
      end # module ClassMethods

      # @!method ancestors
      #   Returns an array of the current object's ancestors, from the root
      #   object to the current parent. If the object has no parent, returns an
      #   empty array. If an error is raised, consider calling
      #   #rebuild_ancestry!
      # 
      #   @raise [Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor]
      #     If one or more of the ancestors is not found in the datastore (the
      #     id is wrong, the object is not persisted, there is a nil value in
      #     ancestor_ids, and so on).
      # 
      #   @return [Array] The objects' ancestors

      # @!method descendents
      #   Returns a scope for all of the descendents of the current object,
      #   i.e. all objects that have the current object as an ancestor.
      # 
      #   @return [Mongoid::Criteria] The criteria for finding the descendents.
      
      # @!method rebuild_ancestry!
      #   Travels up the tree using the #parent method and saves the ancestors
      #   to the :ancestor_ids field. This overwrites the value of
      #   :ancestor_ids on the current object, but not on any of its ancestors.
      # 
      #   @raise [Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor]
      #     If the current object or an ancestor has an invalid #parent.

      # @!method validate_ancestry!
      #   Travels up the tree using the :ancestor_ids and ensures that each
      #   ancestor exists and is persisted to the database, and that the
      #   object's parent correctly matches the last value in its own
      #   :ancestor_ids field.
      # 
      #   @raise [Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor]
      #     If any of the ancestors is not found in the datastore (the id is
      #     wrong, the object is not persisted, there is a nil value in
      #     ancestor_ids, and so on).
      #
      #   @raise [Mongoid::SleepingKingStudios::HasTree::Errors::UnexpectedAncestor]
      #     If there is a mismatch between an object's #parent and the last
      #     value in the object's :ancestor_ids field.
    end # module
  end # module
end # module
