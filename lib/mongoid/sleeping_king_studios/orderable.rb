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

    EMPTY_SCOPE = Object.new.freeze

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
      validate_options name, options
      sort_params = Metadata.normalize_sort_params(sort_params)
      options.update :sort_params => sort_params
      name = options.fetch(:as, Metadata.default_field_name(sort_params, options))
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
      base_name = metadata.field_name.to_s.gsub(/_order\z/,'')

      callbacks = Module.new

      callbacks.send :define_method, :"update_#{base_name}_on_save" do
        criteria    = metadata.sort_criteria(base, self)
        ordering    = criteria.to_a
        order_index = ordering.index(self)
        prior_index = send(metadata.field_was)

        return if order_index.nil? && prior_index.nil?

        # Update the current instance.
        self[metadata.field_name] = order_index

        if metadata.scope?
          order_scope = send(metadata.scope)
          prior_scope = send(metadata.scope_was)

          # If the scope value has changed, we also need to update the ordering
          # for values in the previous scope.
          if order_scope != prior_scope
            prior_criteria = metadata.sort_criteria(base, prior_scope).where(metadata.field_name.gt => prior_index)
            prior_ordering = prior_criteria.to_a

            prior_ordering.each_with_index do |object, i|
              object.set(metadata.field_name => (prior_index + i))
            end # each

            # We only need to update the new scope after the inserted value, even
            # if the prior value was less.
            least_index = order_index
          else
            # Determine the lesser of the new and previous index values so
            # subsequent-indexed documents can be updated.
            least_index = (order_index && prior_index) ?
              [order_index, prior_index].min :
              (order_index || prior_index)
          end # if-else
        else
          # Determine the lesser of the new and previous index values so
          # subsequent-indexed documents can be updated.
          least_index = (order_index && prior_index) ?
            [order_index, prior_index].min :
            (order_index || prior_index)
        end # if

        # If our new value is nil, the record won't appear in the ordering, so
        # we have to update it manually.
        set(metadata.field_name => nil) if order_index.nil?

        # Atomically update the subsequent documents in the collection.
        ordering[least_index..-1].each_with_index do |object, i|
          object.set(metadata.field_name => (least_index + i))
        end unless least_index.nil? # each
      end # method

      callbacks.send :define_method, :"update_#{base_name}_on_destroy" do
        criteria    = metadata.sort_criteria(base, self)
        ordering    = criteria.to_a
        prior_index = send(metadata.field_was)

        return if prior_index.nil?

        ordering[prior_index..-1].each_with_index do |object, i|
          object.set(metadata.field_name => (prior_index + i))
        end # each
      end # method

      base.send :include, callbacks

      base.after_save :"update_#{base_name}_on_save"

      base.after_destroy :"update_#{base_name}_on_destroy"
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

      # Define instance-level helpers.
      instance_methods = Module.new

      instance_methods.send :define_method, :"next_#{base_name}" do |scope = base|
        metadata.filter_criteria(scope, self).asc(metadata.field_name).
          where(metadata.field_name.gt => send(metadata.field_name)).limit(1).first
      end # method

      instance_methods.send :define_method, :"prev_#{base_name}" do |scope = base|
        metadata.filter_criteria(scope, self).desc(metadata.field_name).
          where(metadata.field_name.lt => send(metadata.field_name)).limit(1).first
      end # method

      base.send :include, instance_methods

      # Define class-level helpers.
      class_methods = Module.new

      extract_scope_criteria = ->(scope) {
        criteria = case
        when scope.is_a?(Class)
          scope.try(:all)
        when scope.is_a?(Mongoid::Criteria)
          scope
        when scope.is_a?(Hash)
          base.where(scope)
        when metadata.scope?
          base.where(metadata.scope => scope)
        else
          base
        end # when

        if metadata.scope? && !criteria.selector.key?(metadata.scope.to_s)
          raise ArgumentError.new "this ordering is scoped by #{metadata.scope} -- provide a #{metadata.scope} value or a criteria filtering results by #{metadata.scope}"
        end # if

        criteria
      } # end lambda

      class_methods.send :define_method, :"first_#{base_name}" do |scope = base|
        criteria = extract_scope_criteria.call(scope)

        metadata.filter_criteria(criteria).asc(metadata.field_name).limit(1).first
      end # method

      class_methods.send :define_method, :"last_#{base_name}" do |scope = base|
        criteria = extract_scope_criteria.call(scope)

        metadata.filter_criteria(criteria).desc(metadata.field_name).limit(1).first
      end # method

      reorder_scoped_criteria = ->(criteria) {
        criteria.to_a.each_with_index do |record, index|
          record.set(metadata.field_name => index)
        end # each
      } # end lambda

      class_methods.send :define_method, :"reorder_#{base_name}!" do |scope = EMPTY_SCOPE|
        if metadata.scope?
          if scope == EMPTY_SCOPE
            base.update_all(metadata.field_name => nil)

            all_scopes = base.pluck(metadata.scope).uniq

            all_scopes.each do |scope|
              reorder_scoped_criteria.call(metadata.sort_criteria(base, scope))
            end # each
          else
            criteria = metadata.sort_criteria(base, scope)

            criteria.update_all(metadata.field_name => nil)

            reorder_scoped_criteria.call(criteria)
          end # if-else
        else
          base.update_all(metadata.field_name => nil)

          reorder_scoped_criteria.call(metadata.sort_criteria(base))
        end # if-else
      end # method

      base.extend class_methods
    end # module method define_helpers

    # Returns a list of options that are valid for this concern.
    #
    # @return [Array<Symbol>] The list of valid options.
    def self.valid_options
      super + %i(
        as
        filter
        scope
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

      # @!method first_ordering_name
      #   Finds the first document, based on the stored ordering values.
      #
      #   The generated name of this method will depend on the sort params or the
      #   :as option provided. For example, :as => :alphabetical_order will
      #   result in an instance method #first_alphabetical.
      #
      #   @return [Mongoid::Document, nil] The first document in the order, or
      #     nil if there are no documents in the collection.

      # @!method last_ordering_name
      #   Finds the last document, based on the stored ordering values.
      #
      #   The generated name of this method will depend on the sort params or the
      #   :as option provided. For example, :as => :alphabetical_order will
      #   result in an instance method #last_alphabetical.
      #
      #   @return [Mongoid::Document, nil] The last document in the order, or nil
      #     if there are no documents in the collection.

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
