# lib/mongoid/sleeping_king_studios/sluggable/metadata.rb

require 'mongoid/sleeping_king_studios/concern/metadata'

module Mongoid::SleepingKingStudios
  module Sluggable
    class Metadata < Mongoid::SleepingKingStudios::Concern::Metadata
      def attribute
        self[:attribute].to_s.intern
      end # method attribute

      def attribute?
        !!self[:attribute]
      end # method attribute?

      def lockable?
        !!self[:lockable]
      end # method lockable?

      def value_to_slug value
        value.to_s.parameterize
      end # method value_to_slug
    end # class Metadata
  end # module
end # module
