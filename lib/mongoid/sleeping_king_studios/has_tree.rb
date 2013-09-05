# lib/mongoid/sleeping_king_studios/tree.rb

require 'mongoid/sleeping_king_studios'

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
  # Since 0.4.0, you must call the class method ::has_tree in order to set up
  # the parent and children relations. You can pass optional parameters into
  # this method to customise the created relations, including the names of the
  # relations.
  # 
  # @example Setting up the tree with alternate relation names:
  #   class EvilEmployee
  #     include Mongoid::Document
  #     include Mongoid::SleepingKingStudios::Tree
  #     
  #     has_tree { :relation_name => 'overlord' },
  #       { :relation_name => 'minions', :dependent => :destroy }
  #   end # class
  # 
  # @since 0.2.0
  module HasTree
    extend ActiveSupport::Concern

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
      # Sets up the relations necessary for the tree structure.
      # 
      # @param [Hash] options_for_parent The options for the belongs_to
      #   relation. Available options include :relation_name (see below), and
      #   any options normally supported by a :belongs_to relation.
      # @option options_for_parent [Symbol] :relation_name (:parent) The name
      #   of the belongs_to relation.
      # 
      # @param [Hash] options_for_children The options for the has_many
      #   relation. Available options include :relation_name (see below), and
      #   any options normally supported by a :has_many relation.
      # @option options_for_children [Symbol] :relation_name (:children) The
      #   name of the has_many relation.
      # 
      # @since 0.4.0
      def has_tree options_for_parent = {}, options_for_children = {}
        p_opts = { :relation_name => :parent,   :class_name => self.name }
        c_opts = { :relation_name => :children, :class_name => self.name }
        
        p_opts.update(options_for_parent)   if Hash === options_for_parent
        c_opts.update(options_for_children) if Hash === options_for_children

        p_opts.update :inverse_of => c_opts[:relation_name]
        c_opts.update :inverse_of => p_opts[:relation_name]
        
        belongs_to p_opts.delete(:relation_name), p_opts
        has_many   c_opts.delete(:relation_name), c_opts

        self
      end # class method has_tree

      # Returns a Criteria specifying all root objects, e.g. objects with no
      # parent object.
      # 
      # @return [Mongoid::Criteria]
      def roots
        where({ :parent_id => nil })
      end # scope routes
    end # module

    # Returns the root object of the current object's tree.
    # 
    # @return [Tree]
    def root
      parent ? parent.root : self
    end # method root

    # Returns true if the object is a leaf object, e.g. has no child objects.
    # 
    # @return [Boolean] True if the object has no children; otherwise false.
    def leaf?
      children.empty?
    end # method leaf?

    # Returns true if the object is a root object, e.g. has no parent object.
    # 
    # @return [Boolean] True if the object has no parent; otherwise false.
    def root?
      parent.nil?
    end # method root?
  end # module
end # module
