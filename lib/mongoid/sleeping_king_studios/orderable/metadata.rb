# lib/mongoid/sleeping_king_studios/orderable/metadata.rb

require 'mongoid/sleeping_king_studios/concern/metadata'

module Mongoid::SleepingKingStudios
  module Orderable
    # Stores information about an Orderable concern.
    class Metadata < Mongoid::SleepingKingStudios::Concern::Metadata
      # @param [Symbol, String] name The name of the concern or relation.
      # @param [Hash] properties The properties of the concern or relation.
      def initialize name, properties = {}
        super

        self[:sort_params] = case sort_params
        when Array
          properties[:sort_params].reduce({}) do |hsh, param|
            hsh.merge parse_sort_param(param)
          end # each
        when Hash
          properties[:sort_params].each.with_object({}) do |(key, value), hsh|
            hsh[key] = parse_sort_direction(value)
          end # each
        when Symbol, Origin::Key
          parse_sort_param(properties[:sort_params])
        end # case
      end # method initialize

      # @return [Boolean] True if the sort is descending; otherwise false.
      def descending?
        !!self[:descending]
      end # method descending?

      # The name of the field used to store the order.
      #
      # @return [Symbol] The field name.
      def field_name
        fetch(:as, default_field_name).intern
      end # method field_name

      # @return [Boolean] True if a custom field name is defined; otherwise
      # false.
      def field_name?
        !!self[:as]
      end # method field_name

      # The name of the dirty tracking method for the order field.
      # 
      # @return [Symbol] The method name.
      def field_was
        :"#{field_name}_was"
      end # method field_was

      # The name of the writer for the order field.
      # 
      # @return [Symbol] The method name.
      def field_writer
        :"#{field_name}="
      end # method field_writer

      # The criteria to filter only the desired collection items to sort.
      # 
      # @param [Mongoid::Criteria] criteria The base criteria to modify using
      #   the filter params.
      # 
      # @return [Mongoid::Criteria]
      def filter_criteria criteria
        filter_params? ? criteria.where(filter_params) : criteria
      end # method filter_criteria

      # The options (if any) to filter the collection by prior to sorting.
      # 
      # @return [Hash]
      def filter_params
        self[:filter]
      end # method filter_params

      # @return [Boolean] True if filter params are defined; otherwise false.
      def filter_params?
        !!self[:filter]
      end # method filter_params?

      # The criteria to be used when sorting the collection.
      # 
      # @param [Mongoid::Criteria] criteria The base criteria to modify using
      #   the sort params.
      # 
      # @return [Mongoid::Criteria]
      def sort_criteria criteria
        filter_criteria(criteria).order_by(sort_params)
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
        
      end # method sort_params=

      private

      def default_field_name
        sort_params.map { |key, value|
          "#{key}_#{value == 1 ? 'asc' : 'desc'}"
        }.join('_') + '_order'
      end # method default_field_name

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
