# lib/mongoid/sleeping_king_studios/sluggable.rb

require 'mongoid/sleeping_king_studios'

module Mongoid::SleepingKingStudios
  module Sluggable
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :sluggable_options

      def slugify attribute, **options
        @sluggable_options = options.merge :attribute => attribute.to_s.intern

        field :slug, :type => String

        validates :slug, :presence => true

        before_validation do
          self.slug = to_slug
        end # before validation callback
      end # class method slugify
    end # module

    def to_slug
      raw = (self.send self.class.sluggable_options[:attribute]) || ""
      raw.gsub!(/'/,'')
      raw.parameterize
    end # method to_slug
  end # module
end # module
