# lib/mongoid/sleeping_king_studios/orderable/metadata.rb

require 'mongoid/sleeping_king_studios/concern/metadata'

module Mongoid::SleepingKingStudios
  module Orderable
    # Stores information about an Orderable concern.
    class Metadata < Mongoid::SleepingKingStudios::Concern::Metadata
      def initialize name, properties = {}
        super

        self[:field_name] = properties[:as] if properties.has_key?(:as)
      end # constructor

      # The name of the attribute used to determine the order.
      # 
      # @return [Symbol] The attribute name.
      def attribute
        self[:attribute].to_s.intern
      end # method attribute

      # @return [Boolean] True if the attribute is defined; otherwise false.
      def attribute?
        !!self[:attribute]
      end # method attribute?

      # The name of the field used to store the order.
      #
      # @return [Symbol] The field name.
      def field_name
        fetch(:field_name, "#{attribute}_order").intern
      end # method field_name

      # @return [Boolean] True if a custom field name is defined; otherwise
      # false.
      def field_name?
        !!self[:field_name]
      end # method field_name

      # The name of the writer for the order field.
      # 
      # @return [Symbol] The method name.
      def field_writer
        :"#{field_name}="
      end # method field_writer

      # @return [Boolean] True if nil values are ordered; otherwise false;
      def order_nil?
        !!self[:order_nil?]
      end # method order_nil?
    end # class
  end # module
end # module
