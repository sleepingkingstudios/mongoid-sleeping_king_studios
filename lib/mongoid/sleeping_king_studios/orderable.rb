# lib/mongoid/sleeping_king_studios/orderable.rb

require 'mongoid/sleeping_king_studios/orderable/metadata'

module Mongoid::SleepingKingStudios
  # @since 0.7.0
  module Orderable
    extend ActiveSupport::Concern
    extend Mongoid::SleepingKingStudios::Concern

    def self.apply base, sort_params, options
      name = :orderable
      validate_options    name, options
      options.update :sort_params => sort_params
      meta = characterize name, options, Metadata
      meta.sort_params  = sort_params

      relate base, name, meta

      define_fields    base, meta
      define_callbacks base, meta
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

    def self.define_callbacks base, metadata
      base.after_save do
        criteria = metadata.sort_criteria(base)
        
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
            set(metadata.field_name => nil)
          end # unless
        end # if

        ordering[order_index..-1].each_with_index do |object, i|
          object.set(metadata.field_name => (order_index + i))
        end # each
      end # callback
    end # module

    # Returns a list of options that are valid for this concern.
    # 
    # @return [Array<Symbol>] The list of valid options.
    def self.valid_options
      super + %i(
        as
        filter
      ) # end array
    end # module method valid options

    module ClassMethods
      def cache_ordering *sort_params, **options
        concern = Mongoid::SleepingKingStudios::Orderable
        concern.apply self, sort_params, options
      end # class method slugify
    end # module
  end # module
end # module
