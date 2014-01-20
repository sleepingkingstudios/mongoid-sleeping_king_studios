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

      # @return [Boolean] True if the sort is descending; otherwise false.
      def descending?
        !!self[:descending]
      end # method descending?

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

      # The criteria to be used when sorting the collection.
      # 
      # @return [Mongoid::Criteria]
      def sort_criteria base
        base.all.order_by(sort_params)
      end # method sort_criteria

      # The options to be passed into Criteria#sort when determining the order
      # of the collection items.
      #
      # @return [Hash<Symbol, Integer>] Hash, with field names as keys and
      #   values of 1 or -1 for ascending and descendings sorts, respectively.
      def sort_params
        self[:sort_params]
      end # method sort_params

      # Parses and sets the sort params.
      # 
      # @param [Object] params The options to generate the sort params.
      def sort_params= params
        case params
        when Array
          self[:sort_params] = params.reduce({}) do |hsh, param|
            hsh.merge parse_sort_param(param)
          end # each
        when Hash
          self[:sort_params] = params.each.with_object({}) do |(key, value), hsh|
            hsh[key] = parse_sort_direction(value)
          end # each
        when Symbol, Origin::Key
          self[:sort_params] = parse_sort_param(params)
        end # case
      end # method sort_params=

      private

      def parse_sort_param param
        case param
        when Array
          { param[0] => parse_sort_direction(param[1]) }
        when Origin::Key
          { param.name => param.operator }
        when Symbol
          { param => 1 }
        end # case
      end # method sort_param=

      def parse_sort_direction direction
        (direction == -1 || direction.to_s.downcase == 'desc') ? -1 : 1
      end # method parse_sort_direction
    end # class
  end # module
end # module
