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
        # @overload cache_ancestry()
        #   Adds the :ancestry_id field, the #ancestors and #descendents
        #   scopes, and redefines #parent_id= to update the :ancestry_id
        #   field on the object and its descendents.
        # 
        #   Do not call this method directly; rather, add a
        #   :cache_ancestry => true options to the call to ::has_tree.
        def cache_ancestry **options
          parent_name   = options[:children][:inverse_of]
          children_name = options[:parent][:inverse_of]

          field :ancestor_ids, :type => Array, :default => []

          alias_method :"set_parent_id", :"#{parent_name}_id="
          private :set_parent_id
          re_define_method "#{parent_name}_id=" do |value|
            old_ancestor_ids = ancestor_ids.dup

            set_parent_id value
            new_ancestor_ids = parent ? parent.ancestor_ids + [parent.id] : []

            descendents.each do |descendent|
              ary = descendent.ancestor_ids.dup
              ary[0..old_ancestor_ids.count] = new_ancestor_ids + [id]
              descendent.update_attributes :ancestor_ids => ary
            end # each
            
            self.send :ancestor_ids=, new_ancestor_ids
          end # method #{parent_name}_id=
        end # class method cache_ancestry
      end # module ClassMethods

      # Returns an array of the current object's ancestors, from the root
      # object to the current parent. If the object has no parent, returns an
      # empty array. If an error is raised, consider calling #rebuild_ancestry!
      # 
      # @raise [Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor]
      #   If one or more of the ancestors is not found in the datastore (the id
      #   is wrong, the object is not persisted, there is a nil value in
      #   ancestor_ids, and so on).
      # 
      # @return [Array] The objects' ancestors
      def ancestors
        self.class.find(ancestor_ids)
      rescue Mongoid::Errors::DocumentNotFound, Mongoid::Errors::InvalidFind
        raise Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor.new ancestor_ids
      end # method ancestors

      # Returns a scope for all of the descendents of the current object, i.e.
      # all objects that have the current object as an ancestor.
      # 
      # @return [Mongoid::Criteria] The criteria for finding the descendents.
      def descendents
        criteria = self.class.all

        ancestor_ids.each_with_index do |ancestor_id, index|
          criteria = criteria.where(:"ancestor_ids.#{index}" => ancestor_id)
        end # each

        criteria.where(:"ancestor_ids.#{ancestor_ids.count}" => id)
      end # scope descendents

      # Travels up the tree using the #parent method and saves the ancestors to
      # the :ancestor_ids field. This overwrites the value of :ancestor_ids on
      # the current object, but not on any of its ancestors.
      # 
      # @raise [Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor]
      #   If the current object or an ancestor has an invalid #parent.
      def rebuild_ancestry!
        ary, object = [], self
        while object.parent
          ary.unshift object.parent.id
          object = object.parent
        end # while
        self.send :ancestor_ids=, ary
      rescue Mongoid::Errors::DocumentNotFound
        raise Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor.new object.parent_id
      end # method rebuild_ancestry!

      # Travels up the tree using the :ancestor_ids and ensures that each
      # ancestor exists and is persisted to the database, and that the
      # object's parent correctly matches the last value in its own
      # :ancestor_ids field.
      # 
      # @raise [Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor]
      #   If any of the ancestors is not found in the datastore (the id is
      #   wrong, the object is not persisted, there is a nil value in
      #   ancestor_ids, and so on).
      #
      # @raise [Mongoid::SleepingKingStudios::HasTree::Errors::UnexpectedAncestor]
      #   If there is a mismatch between an object's #parent and the last value
      #   in the object's :ancestor_ids field.
      def validate_ancestry!
        return if ancestor_ids.empty?

        ancestors = []
        ancestor_ids.each_with_index do |ancestor_id, index|
          begin
            ancestor = self.class.find(ancestor_id)
            ancestors << ancestor

            if index > 0 && ancestor.parent_id != ancestor_ids[index - 1]
              # If the ancestor's parent is not the same as the previous
              # ancestor.
              raise Mongoid::SleepingKingStudios::HasTree::Errors::UnexpectedAncestor.new ancestor.parent_id, ancestor_ids[index - 1]
            end # if
          rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
            # If the ancestor id is nil, or the ancestor does not exist.
            raise Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor.new ancestor_id
          end # begin-rescue
        end # each
      end # method validate_ancestry!
    end # module
  end # module
end # module
