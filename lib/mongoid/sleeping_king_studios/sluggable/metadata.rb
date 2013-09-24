# lib/mongoid/sleeping_king_studios/sluggable/metadata.rb

require 'mongoid/sleeping_king_studios/concern/metadata'

module Mongoid::SleepingKingStudios
  module Sluggable
    # Stores information about a Sluggable concern.
    class Metadata < Mongoid::SleepingKingStudios::Concern::Metadata
      # The base attribute used to determine the slug value.
      # 
      # @return [Symbol] The attribute name.
      def attribute
        self[:attribute].to_s.intern
      end # method attribute

      # @return [Boolean] True if the attribute is defined; otherwise false.
      def attribute?
        !!self[:attribute]
      end # method attribute?

      # If true, the slug can be "locked" by setting the slug value directly or
      # by setting the value of the :slug_lock field to true. A locked slug is
      # not overwritten when the base field is updated.
      # 
      # @return [Boolean] True if the slug is lockable; otherwise false.
      def lockable?
        !!self[:lockable]
      end # method lockable?

      # Converts the given value to a valid slug string. Refactoring this into
      # the metadata will permit customization of the value -> slug mapping in
      # the future.
      # 
      # @param [Object] value The value to convert into a slug.
      # 
      # @return [String] The converted value.
      def value_to_slug value
        value.to_s.parameterize
      end # method value_to_slug
    end # class Metadata
  end # module
end # module
