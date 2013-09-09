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

    # Get the valid options allowed with this concern.
    # 
    # @return [ Array<Symbol> ] The valid options.
    #
    # @since 0.4.1
    def self.valid_options
      %i(children parent)
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
      # 
      #   @raise [ Mongoid::Errors::InvalidOptions ] If the options are invalid.
      #
      # @since 0.4.0
      def has_tree **options
        validate_options options

        p_opts  = { :relation_name => :parent,   :class_name => self.name }
        c_opts  = { :relation_name => :children, :class_name => self.name }
        
        p_opts.update(options[:parent])   if Hash === options[:parent]
        c_opts.update(options[:children]) if Hash === options[:children]

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

      private

      # Determine if the provided options are valid for the concern.
      #
      # @param [ Hash ] options The options to check.
      #
      # @raise [ Mongoid::Errors::InvalidOptions ] If the options are invalid.
      def validate_options options
        valid_options = Mongoid::SleepingKingStudios::HasTree.valid_options
        options.keys.each do |key|
          if !valid_options.include?(key)
            raise Mongoid::Errors::InvalidOptions.new(
              :has_tree,
              key,
              valid_options
            ) # end InvalidOptions
          end # if
        end # each
      end # class method validate_options
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
