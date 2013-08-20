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
  # @since 0.2.0
  module Tree
    extend ActiveSupport::Concern

    # @!method parent
    #   Returns the parent object, or nil if the object is a root.
    # 
    #   @return [Tree, nil]

    # @!method children
    #   Returns the list of child objects.
    # 
    #   @return [Array<Tree>]

    included do |base|
      belongs_to :parent,   :class_name => base.name, :inverse_of => :children
      has_many   :children, :class_name => base.name, :inverse_of => :parent
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
