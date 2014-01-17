# lib/mongoid/sleeping_king_studios/has_tree/cache_ancestry.rb

require 'mongoid/sleeping_king_studios'
require 'mongoid/sleeping_king_studios/concern'
require 'mongoid/sleeping_king_studios/has_tree/cache_ancestry/errors/missing_ancestor_error'
require 'mongoid/sleeping_king_studios/has_tree/cache_ancestry/errors/unexpected_ancestor_error'

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
      extend Mongoid::SleepingKingStudios::Concern

      # @api private
      # 
      # Sets up the ancestry caching concern.
      # 
      # @param [Class] base The base class into which the concern is mixed in.
      # @param [Hash] options The options for the relation.
      # 
      # @since 0.6.0
      def self.apply base, metadata
        name = :has_tree_cache_ancestry
        validate_options name, metadata.properties

        define_fields    base, metadata
        define_accessors base, metadata
        define_helpers   base, metadata
      end # class method apply

      # @api private
      # 
      # Overwrites the parent id setter to update the ancestor ids field,
      # and defines the ancestors and descendents methods.
      # 
      # @param [Class] base The base class into which the concern is mixed in.
      # @param [Metadata] metadata The metadata for the relation.
      # 
      # @since 0.6.0
      def self.define_accessors base, metadata
        concern          = self
        parent_id_writer = base.instance_method metadata.parent_foreign_key_writer
        field_writer     = base.instance_method metadata.field_writer

        # Redefine the setter for the base field to update the foreign key as
        # well. The default field is :id, but can be customized to refer to
        # another field on the model.
        base.re_define_method metadata.field_writer do |value|
          old_ancestor_ids = send(metadata.foreign_key).dup

          field_writer.bind(self).call value

          new_ancestor_ids = (send(metadata.parent_name) ?
            send(metadata.parent_name).send(metadata.foreign_key) :
            []) + [send(metadata.field_name)]

          send :"#{metadata.foreign_key}=", new_ancestor_ids
        end # method

        # Redefine the foreign key setter to update the descendents' foreign
        # keys. What should actually be happening here is updating the
        # current foreign key, but not the *persisted* foreign key local
        # variable that I'm going to have to add.
        base.re_define_method metadata.parent_foreign_key_writer do |value|
          old_ancestor_ids = send(metadata.foreign_key).dup

          parent_id_writer.bind(self).call value
          new_ancestor_ids = send(metadata.parent_name) ?
            send(metadata.parent_name).send(metadata.foreign_key) + [send(metadata.field_name)] :
            []

          descendents = concern.build_ancestry_criteria base, metadata, old_ancestor_ids
          descendents = descendents.where :id => { '$ne' => self.id }
          descendents.each do |descendent|
            ary = descendent.send(metadata.foreign_key).dup
            ary[0...old_ancestor_ids.count] = new_ancestor_ids
            descendent.update_attributes metadata.foreign_key => ary
          end # each
          
          send :"#{metadata.foreign_key}=", new_ancestor_ids
        end # method

        # Define the scope for ancestors of the current object.
        base.send :define_method, metadata.relation_name do
          return [] if (values = send(metadata.foreign_key)[0...-1]).blank?

          concern.find_by_ancestry self.class, metadata, values
        end # method

        # Define the scope for descendents of the current object.
        base.send :define_method, :descendents do
          criteria = concern.build_ancestry_criteria base, metadata, send(metadata.foreign_key)
          criteria.where :id => { '$ne' => self.id }
        end # method descendents
      end # class method define_fields

      # @api private
      # 
      # Defines the foreign key field on the base class.
      # 
      # @param [Class] base The base class into which the concern is mixed in.
      # @param [Metadata] metadata The metadata for the relation.
      # 
      # @since 0.6.0
      def self.define_fields base, metadata
        base.send :field, metadata.foreign_key, :type => Array, :default => ->() { [send(metadata.field_name)] }
      end # class method define_fields

      # @api private
      # 
      # Defines the rebuild and validate ancestry helper methods.
      # 
      # @param [Class] base The base class into which the concern is mixed in.
      # @param [Metadata] metadata The metadata for the relation.
      # 
      # @since 0.6.0
      def self.define_helpers base, metadata
        concern = self
        base.send :define_method, :rebuild_ancestry! do
          begin
            ary, object = [], self
            while object.send(metadata.parent_name)
              ary.unshift object.send(metadata.parent_name).send(metadata.field_name)
              object = object.send(metadata.parent_name)
            end # while
            self.send :"#{metadata.foreign_key}=", ary
          rescue Mongoid::Errors::DocumentNotFound
            raise Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor.new "#{relation_name}", object.send(metadata.parent_foreign_key)
          end # begin-rescue
        end # method rebuild_ancestry!

        base.send :define_method, :validate_ancestry do
          ancestors = []
          send(metadata.foreign_key)[0...-1].each_with_index do |ancestor_id, index|
            begin
              ancestor = concern.find_one_by_ancestry base, metadata, send(metadata.foreign_key)[0..index]
              ancestors << ancestor

              if index == 0

              else
                if ancestor.send(metadata.parent_foreign_key).nil?
                  # If the ancestor's parent is missing.
                  raise Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Errors::MissingAncestorError.new base, metadata, ancestors[index - 1].send(metadata.field_name)
                elsif ancestor.send(metadata.parent_foreign_key) != ancestors[index - 1].send(:id)
                  # If the ancestor's parent is not the same as the previous
                  # ancestor.
                  binding.pry if $BINDING_SLUG
                  raise Mongoid::SleepingKingStudios::HasTree::Errors::UnexpectedAncestor.new "#{metadata.relation_name}", ancestor.send(metadata.parent_name).send(metadata.field_name), ancestors[index - 1].send(metadata.field_name)
                end # if
              end # if
            rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
              # If the ancestor id is nil, or the ancestor does not exist.
              raise Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor.new "#{metadata.relation_name}", ancestor_id
            end # begin-rescue
          end # each with index
        end # method validate_ancestry!
      end # class method define_helpers

      def self.build_ancestry_criteria base, metadata, values, criteria = nil
        criteria = base.all unless Mongoid::Criteria === criteria

        values.each_with_index do |value, index|
          criteria = criteria.where(:"#{metadata.foreign_key}.#{index}" => value)
        end # each

        criteria
      end # class method build_ancestry_criteria

      def self.find_one_by_ancestry base, metadata, values
        if :id == metadata.field_name
          base.find values.last
        else
          objects = base.where(metadata.foreign_key => values).to_a

          # If there are no objects, then was unable to find object. If there
          # is more than one object, then the foreign key is not unique.
          if objects.count == 0
            raise Mongoid::SleepingKingStudios::HasTree::CacheAncestry::Errors::MissingAncestorError.new base, metadata, values
          elsif objects.count > 1
            raise Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor.new "#{metadata.relation_name}", values
          end # if-elsif

          objects.first
        end # if-else
      rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
        # If the ancestor id is nil, or the ancestor does not exist.
        raise Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor.new "#{metadata.relation_name.to_s.singularize}", values
      end # class method find_one_by_ancestry

      def self.find_by_ancestry base, metadata, values
        if :id == metadata.field_name
          base.find values
        else
          folded = [*0...values.count].map do |index|
            values[0..index]
          end # map
          objects = base.where(metadata.foreign_key => { '$in' => folded }).to_a

          # If there are fewer objects than expected ancestors, then was unable
          # to find one or more ancestors.
          if objects.count < values.count
            raise Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor.new "#{metadata.relation_name}", values
          end # if
          
          objects
        end # if-else
      rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
        # If the ancestor id is nil, or the ancestor does not exist.
        raise Mongoid::SleepingKingStudios::HasTree::Errors::MissingAncestor.new "#{metadata.relation_name}", values
      end # class method find_by_ancestry

      # Get the valid options allowed with this concern.
      # 
      # @return [ Array<Symbol> ] The valid options.
      #
      # @since 0.5.1
      def self.valid_options
        %i(
          children_name
          field_name
          foreign_key
          parent_name
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
