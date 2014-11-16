# lib/mongoid/sleeping_king_studios/tree.rb

require 'mongoid/sleeping_king_studios'
require 'mongoid/sleeping_king_studios/concern'
require 'mongoid/sleeping_king_studios/has_tree/metadata'
require 'mongoid/sleeping_king_studios/has_tree/cache_ancestry'
require 'sleeping_king_studios/tools/object_tools'

module Mongoid::SleepingKingStudios
  # Adds a belongs_to parent relation and a has_many children relation to set
  # up a basic tree structure, as well as several helper methods.
  #
  # @note From 0.2.0 to 0.3.1, was Mongoid::SleepingKingStudios::Tree.
  #
  # @example Setting up the tree:
  #   class SluggableDocument
  #     include Mongoid::Document
  #     include Mongoid::SleepingKingStudios::Tree
  #
  #     has_tree
  #   end # class
  #
  # Since 0.4.1, you must call the class method ::has_tree in order to set up
  # the parent and children relations. You can pass optional parameters into
  # this method to customise the created relations, including the names of the
  # relations.
  #
  # @example Setting up the tree with alternate relation names:
  #   class EvilEmployee
  #     include Mongoid::Document
  #     include Mongoid::SleepingKingStudios::Tree
  #
  #     has_tree :parent => { :relation_name => 'overlord' },
  #       :children => { :relation_name => 'minions', :dependent => :destroy }
  #   end # class
  #
  # @since 0.2.0
  module HasTree
    extend ActiveSupport::Concern
    extend Mongoid::SleepingKingStudios::Concern

    # @api private
    #
    # Sets up the has_tree relation, creating fields, accessors and
    # validations.
    #
    # @param [Class] base The base class into which the concern is mixed in.
    # @param [Hash] options The options for the relation.
    #
    # @since 0.6.0
    def self.apply base, options
      options[:parent]   ||= {}
      options[:children] ||= {}

      options[:parent][:inverse_of]   = options[:children].fetch(:relation_name, :children)
      options[:children][:inverse_of] = options[:parent].fetch(:relation_name,   :parent)

      name = :has_tree
      validate_options    name, options
      meta = characterize name, options, Metadata

      relate base, name, meta

      define_relations base, meta
      define_helpers   base, meta

      if meta.cache_ancestry?
        concern = Mongoid::SleepingKingStudios::HasTree::CacheAncestry
        concern.send :apply, base, meta.cache_ancestry
      end # if
    end # class method apply

    # @api private
    #
    # Sets up the helper methods for the relations as follows.
    #
    # Defines the following class methods:
    # - ::roots
    #
    # Defines the following instance methods:
    # - #leaf?
    # - #root
    # - #root?
    #
    # @param [Class] base The base class into which the concern is mixed in.
    # @param [Metadata] metadata The metadata for the relation.
    #
    # @since 0.6.0
    def self.define_helpers base, metadata
      eigenclass = SleepingKingStudios::Tools::ObjectTools.eigenclass(base)

      eigenclass.send :define_method, :roots do
        where({ :"#{metadata.parent.relation_name}_id" => nil })
      end # class method roots

      base.send :define_method, :root do
        parent = send(metadata.parent.relation_name)
        parent ? parent.root : self
      end # method root

      base.send :define_method, :leaf? do
        send(metadata.children.relation_name).blank?
      end # method root?

      base.send :define_method, :root? do
        send(metadata.parent.relation_name).nil?
      end # method root?

      base.send :define_method, :siblings do
        self.class.where(:id => { "$ne" => self.id }).where(metadata.foreign_key => self.send(metadata.foreign_key))
      end # method siblings
    end # class method define_helpers

    # @api private
    #
    # Sets up the parent and children relations.
    #
    # @param [Class] base The base class into which the concern is mixed in.
    # @param [Metadata] metadata The metadata for the relation.
    #
    # @since 0.6.0
    def self.define_relations base, metadata
      parent_options = metadata.parent.properties.dup
      parent_options.update :class_name => base.name
      parent_options.delete :relation_name

      children_options = metadata.children.properties.dup
      children_options.update :class_name => base.name
      children_options.delete :relation_name

      base.belongs_to metadata.parent.relation_name,   parent_options
      base.has_many   metadata.children.relation_name, children_options
    end # class method define_relations

    # Get the valid options allowed with this concern.
    #
    # @return [ Array<Symbol> ] The valid options.
    #
    # @since 0.4.1
    def self.valid_options
      %i(
        cache_ancestry
        children
        parent
      ) # end Array
    end # class method valid_options

    # @!method parent
    #   Returns the parent object, or nil if the object is a root.
    #
    #   @return [Tree, nil]

    # @!method children
    #   Returns the list of child objects.
    #
    #   @return [Array<Tree>]

    # Class methods added to the base class via #extend.
    module ClassMethods
      # @overload has_tree(options = {})
      #   Sets up the relations necessary for the tree structure.
      #
      #   @param [Hash] options The options for the relation and the concern as a
      #     whole.
      #   @option options [Hash] :parent ({}) The options for the parent
      #     relation. Supports the :relation_name option, which sets the name of
      #     the tree's :belongs_to relation, as well as any options normally
      #     supported by a :belongs_to relation.
      #   @option options [Hash] :children ({}) The options for the children
      #     relation. Supports the :relation_name options, which sets the name of
      #     the tree's :has_many relation, as well as any options normally
      #     supported by a :has_many relation.
      #   @option options [Boolean] :cache_ancestry (false) Stores the chain of
      #     ancestors in an :ancestor_ids array field. Adds the #ancestors and
      #     #descendents scopes.
      #
      #     Warning: Using this option will make many write operations much,
      #     much slower and more resource-intensive. Do not use this option
      #     outside of read-heavy applications with very specific requirements,
      #     e.g. a directory structure where you must access all parent
      #     directories on each page view.
      #
      #   @see Mongoid::SleepingKingStudios::HasTree::CacheAncestry::ClassMethods#cache_ancestry
      #
      #   @raise [ Mongoid::Errors::InvalidOptions ] If the options are invalid.
      #
      # @since 0.4.0
      def has_tree **options
        concern = Mongoid::SleepingKingStudios::HasTree
        concern.apply self, options
      end # class method has_tree

      # @!method roots
      #   Returns a Criteria specifying all root objects, e.g. objects with no
      #   parent object.
      #
      #   @return [Mongoid::Criteria]
    end # module

    # @!method root
    #   Returns the root object of the current object's tree.
    #
    #   @return [Tree]

    # @!method leaf?
    #   Returns true if the object is a leaf object, e.g. has no child objects.
    #
    #   @return [Boolean] True if the object has no children; otherwise false.

    # @!method root?
    #   Returns true if the object is a root object, e.g. has no parent object.
    #
    #   @return [Boolean] True if the object has no parent; otherwise false.

    # @!method siblings
    #   Returns a Criteria specifying all persisted objects in the tree whose
    #   parent is the current object's parent, excluding the current object.
    #
    #   @return [Mongoid::Criteria]
    #
    #   @since 0.6.1
  end # module
end # module
