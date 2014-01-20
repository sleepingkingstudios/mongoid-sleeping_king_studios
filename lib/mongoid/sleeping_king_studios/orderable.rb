# lib/mongoid/sleeping_king_studios/orderable.rb

require 'mongoid/sleeping_king_studios/orderable/metadata'

module Mongoid::SleepingKingStudios
  module Orderable
    extend ActiveSupport::Concern
    extend Mongoid::SleepingKingStudios::Concern

    def self.apply base, attribute, options
      name = :orderable
      validate_options    name, options
      meta = characterize name, options, Metadata
      meta[:attribute] = attribute

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
        ordering    = base.all.order_by(metadata.attribute => :asc).to_a
        order_index = ordering.index(self)
        
        ordering[order_index..-1].each_with_index do |object, i|
          object.set(metadata.field_name => (order_index + i))
        end # ordering
      end # callback
    end # module

    module ClassMethods
      def cache_ordering attribute, **options
        concern = Mongoid::SleepingKingStudios::Orderable
        concern.apply self, attribute, options
      end # class method slugify
    end # module
  end # module
end # module
