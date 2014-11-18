# lib/mongoid/sleeping_king_studios/orderable/metadata.rb

require 'mongoid/sleeping_king_studios/concern/metadata'

module Mongoid::SleepingKingStudios
  module Orderable
    # Stores information about an Orderable concern.
    class Metadata < Mongoid::SleepingKingStudios::Concern::Metadata
      class << self
        def default_field_name sort_params, options = {}
          name = (sort_params.map { |key, value|
            "#{key}_#{value == 1 ? 'asc' : 'desc'}"
          }.join('_'))

          name << "_by_#{options[:scope].to_s.underscore}" if options[:scope]

          name << '_order'

          name.intern
        end # class method default_field_name

        def normalize_sort_params sort_params
          case sort_params
          when Array
            sort_params.reduce({}) do |hsh, param|
              hsh.merge parse_sort_param(param)
            end # each
          when Hash
            sort_params.each.with_object({}) do |(key, value), hsh|
              hsh[key] = parse_sort_direction(value)
            end # each
          when Symbol, Origin::Key
            parse_sort_param(sort_params)
          end # case
        end # class method normalize_sort_params

        private

        def parse_sort_direction direction
          (direction == -1 || direction.to_s.downcase == 'desc') ? -1 : 1
        end # class method parse_sort_direction

        def parse_sort_param param
          case param
          when Array
            { param[0] => parse_sort_direction(param[1]) }
          when Origin::Key
            { param.name => param.operator }
          when Symbol
            { param => 1 }
          end # case
        end # class method parse_sort_param
      end # class << self

      # The name of the field used to store the order.
      #
      # @return [Symbol] The field name.
      def field_name
        fetch(:as, Metadata.default_field_name(self[:sort_params], properties)).intern
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
      def filter_criteria criteria, document
        criteria = criteria.all if criteria.is_a?(Class)

        # Apply filter params.
        criteria = filter_params? ? criteria.where(filter_params) : criteria

        # Apply ordering scope.
        criteria = criteria.where(scope => document.try(scope)) if scope? && !criteria.selector.key?(scope.to_s)

        criteria
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

      # The scope parameter to use when generating or updating document
      # orderings.
      def scope
        self[:scope]
      end # method scope

      # @return [Boolean] True if a scope parameter is set; otherwise false.
      def scope?
        !!self[:scope]
      end # method scope?

      # The criteria to be used when sorting the collection.
      #
      # @param [Mongoid::Criteria] criteria The base criteria to modify using
      #   the sort params.
      #
      # @return [Mongoid::Criteria]
      def sort_criteria criteria, document
        filter_criteria(criteria, document).order_by(self[:sort_params])
      end # method sort_criteria
    end # class
  end # module
end # module
