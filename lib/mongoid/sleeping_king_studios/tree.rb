# lib/mongoid/sleeping_king_studios/tree.rb

require 'mongoid/sleeping_king_studios'

module Mongoid::SleepingKingStudios
  # Adds a belongs_to parent relation and a has_many children relation to set
  # up a basic tree structure, as well as several helper methods.
  # 
  # @example Setting up the tree:
  #   class SluggableDocument
  #     include Mongoid::Document
  #     include Mongoid::SleepingKingStudios::Tree
  #   end # class
  # 
  # Since 0.3.0, you can customise the generated :parent and :children
  # relations by defining optional class methods ::options_for_parent and
  # ::options_for_children, which must return hashes of valid options. These
  # must be defined prior to including this mixin, or the default options will
  # be applied instead.
  # 
  # In addition, you can customise the names of the relations by adding a
  # :relation_name key to either ::options_for hash. The concern will
  # automatically update the respective :inverse_of options to match the
  # updated relation names.
  # 
  # Since 0.3.1, you can additionally customise the name of the class methods
  # used to determine the customised options by changing the value of
  # Tree.options_for_parent_name and Tree.options_for_children_name.
  # 
  # @example Setting up the tree with alternate relation names:
  #   class EvilEmployee
  #     include Mongoid::Document
  # 
  #     def self.options_for_parent
  #       { :relation_name => "overlord" }
  #     end # class method options_for_parent
  # 
  #     def self.options_for_children
  #       { :relation_name => "minions", :dependent => :destroy }
  #     end # class method options_for_children
  # 
  #     include Mongoid::SleepingKingStudios::Tree
  #   end # class
  # 
  # @since 0.2.0
  module Tree
    extend ActiveSupport::Concern

    class << self
      # Gets the name of the method on the base module that is used to find
      # customisation options for the :parent relation.
      # 
      # @return [Symbol] By default, returns :options_for_parent.
      # 
      # @since 0.3.1
      attr_accessor :options_for_parent_name

      # Gets the name of the method on the base module that is used to find
      # customisation options for the :children relation.
      # 
      # @return [Symbol] By default, returns :options_for_children.
      # 
      # @since 0.3.1
      attr_accessor :options_for_children_name
    end # class << self

    self.options_for_parent_name   = :options_for_parent
    self.options_for_children_name = :options_for_children

    # @!method parent
    #   Returns the parent object, or nil if the object is a root.
    # 
    #   @return [Tree, nil]

    # @!method children
    #   Returns the list of child objects.
    # 
    #   @return [Array<Tree>]

    included do |base|
      p_opts = { :relation_name => :parent,   :class_name => base.name }
      c_opts = { :relation_name => :children, :class_name => base.name }
      
      p_opts.update(send Tree.options_for_parent_name)   if respond_to?(Tree.options_for_parent_name)
      c_opts.update(send Tree.options_for_children_name) if respond_to?(Tree.options_for_children_name)

      p_opts.update :inverse_of => c_opts[:relation_name]
      c_opts.update :inverse_of => p_opts[:relation_name]
      
      belongs_to p_opts.delete(:relation_name), p_opts
      has_many   c_opts.delete(:relation_name), c_opts
    end # included

    # Class methods added to the base class via #extend.
    module ClassMethods
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
