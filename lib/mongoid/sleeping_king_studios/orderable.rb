# lib/mongoid/sleeping_king_studios/orderable.rb

require 'mongoid/sleeping_king_studios/orderable/metadata'

module Mongoid::SleepingKingStudios
  # Adds an order field that stores the index of the record relative to the
  # specified sort query. Storing the order in this fashion allows, for
  # example, finding the next or previous records in the set without needing to
  # perform the full sort query each time.
  # 
  # @example Order by Most Recently Created:
  #   class SortedDocument
  #     include Mongoid::Document
  #     include Mongoid::SleepingKingStudios::Ordering
  # 
  #     cache_ordering :created_at.desc, :as => :most_recent_order
  #   end # class
  # 
  # @see ClassMethods#cache_ordering
  # 
  # @since 0.7.0
  module Orderable
    extend ActiveSupport::Concern
    extend Mongoid::SleepingKingStudios::Concern

    # @api private
    # 
    # Sets up the orderable relation, creating fields, callbacks and helper
    # methods.
    # 
    # @param [Class] base The base class into which the concern is mixed in.
    # @param [Symbol, Array, Hash] sort_params The params used to sort the
    #   collection, generating the cached order index.
    # @param [Hash] options The options for the relation.
    def self.apply base, sort_params, options
      name = :orderable
      validate_options    name, options
      options.update :sort_params => sort_params
      meta = characterize name, options, Metadata

      relate base, name, meta

      define_fields    base, meta
      define_callbacks base, meta
      define_helpers   base, meta
    end # module method apply

    # @api private
    # 
    # Creates an order field of type Integer on the base class, and sets the
    # writer to private.
    # 
    # @param [Class] base The base class into which the concern is mixed in.
    # @param [Metadata] metadata The metadata for the relation.
    def self.define_fields base, metadata
      base.send :field,   metadata.field_name, :type => Integer

      base.send :private, metadata.field_writer
    end # module method define_fields

    # @api private
    # 
    # Adds an after_save callback to update the index of the record and all
    # subsequent records in the ordering.
    # 
    # @param [Class] base The base class into which the concern is mixed in.
    # @param [Metadata] metadata The metadata for the relation.
    def self.define_callbacks base, metadata
      base.after_save do
        criteria    = metadata.sort_criteria(base)
        ordering    = criteria.to_a
        order_index = ordering.index(self)

        if order_index.nil?
          if send(metadata.field_was).nil?
            # Both the old and new values are nil, so mission accomplished.
            return
          else
            # The old value wasn't nil, so remember it and set the new value,
            # then start looping through the ordered collection at the old
            # value.
            order_index = send(metadata.field_was)

            # Update the current instance.
            self[metadata.field_name] = nil

            # Set the value in the datastore.
            set(metadata.field_name => order_index)
          end # unless
        else
          # Update the current instance.
          self[metadata.field_name] = order_index
        end # if

        ordering[order_index..-1].each_with_index do |object, i|
          object.set(metadata.field_name => (order_index + i))
        end # each
      end # callback
    end # module method define_callbacks

    # @api private
    #
    # Adds a class-level reorder! helper that loops through the entire
    # collection and updates the ordering of each item.
    # 
    # @param [Class] base The base class into which the concern is mixed in.
    # @param [Metadata] metadata The metadata for the relation.
    def self.define_helpers base, metadata
      base_name = metadata.field_name.to_s.gsub(/_order\z/,'')
      
      name = :"next_#{base_name}"
      base.send :define_method, name do
        base.order_by(metadata.field_name.asc).where(metadata.field_name.gt => send(metadata.field_name)).limit(1).first
      end # method

      name = :"prev_#{base_name}"
      base.send :define_method, name do
        base.order_by(metadata.field_name.desc).where(metadata.field_name.lt => send(metadata.field_name)).limit(1).first
      end # method

      name = :"reorder_#{base_name}!"
      meta = class << base; self; end
      meta.send :define_method, name do
        base.update_all(metadata.field_name => nil)
        
        criteria = metadata.sort_criteria(base)
        ordering = criteria.to_a

        ordering.each_with_index do |record, index|
          record.set(metadata.field_name => index)
        end # each
      end # method
    end # module method define_helpers

    # Returns a list of options that are valid for this concern.
    # 
    # @return [Array<Symbol>] The list of valid options.
    def self.valid_options
      super + %i(
        as
        filter
      ) # end array
    end # module method valid options

    # Class methods added to the base class via #extend.
    module ClassMethods
      # @overload cache_ordering sort_params, options = {}
      #   Creates the order field and sets up the callbacks and helpers.
      # 
      #   @param [Array] sort_params The sort query used to order the
      #     collection. Accepts a subset of the options for a default
      #     Origin sort operation:
      #     - :field_name.desc, :another_field
      #     - { :field_name => -1, :another_field => 1 }
      #     - \[[:field_name, -1], [:another_field, :asc]]
      #   @param [Hash] options The options for the relation.
      #   @option options [Symbol] :as
      #     Sets the name of the generated field and helpers. By default,
      #     uses the name(s) and direction(s) of the fields from the sort
      #     query, e.g. :field_name_asc_another_field_desc_order.
      #   @option options [Hash] :filter
      #     Sets a filter that excludes collection items from the ordering
      #     process. Accepts the same parameters as a Mongoid #where query.
      # 
      #   @raise [Mongoid::Errors::InvalidOptions] If any of the provided
      #     options are invalid.
      def cache_ordering *sort_params, **options
        concern = Mongoid::SleepingKingStudios::Orderable
        concern.apply self, sort_params, options
      end # class method slugify

      # @!method reorder_ordering_name!
      #   Iterates through the entire collection and sets the cached order of
      #   each item to its current order index. Filtered items have their order
      #   set to nil. Normally, this should be taken care of when the items are
      #   saved, but this method allows the process to be reset in case of data
      #   corruption or other issues.
      # 
      #   The generated name of this method will depend on the sort params or
      #   the :as option provided. For example, :as => :alphabetical_order will
      #   result in a class method ::reorder_alphabetical!.
    end # module

    # @!method next_ordering_name
    #   Finds the next document, based on the stored ordering values.
    # 
    #   The generated name of this method will depend on the sort params or the
    #   :as option provided. For example, :as => :alphabetical_order will
    #   result in an instance method #next_alphabetical.
    # 
    #   @return [Mongoid::Document, nil] The next document in the order, or nil
    #     if there are no more documents in the collection.

    # @!method prev_ordering_name
    #   Finds the previous document, based on the stored ordering values.
    # 
    #   The generated name of this method will depend on the sort params or the
    #   :as option provided. For example, :as => :alphabetical_order will
    #   result in an instance method #prev_alphabetical.
    # 
    #   @return [Mongoid::Document, nil] The previous document in the order, or
    #     nil if there are no prior documents in the collection.
  end # module
end # module
