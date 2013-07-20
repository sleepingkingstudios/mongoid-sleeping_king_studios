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

        validates :slug,
          :presence => true,
          :format => {
            :with => /\A[a-z0-9\-]+\z/,
            :message => 'must be lower-case characters a-z, digits 0-9, and hyphens "-"'
          } # end format

        before_validation do
          return if self.class.sluggable_options[:lockable] && self.slug_lock
          self.slug = to_slug
        end # before validation callback

        # Lockable
        if options.fetch(:lockable, false)
          field :slug_lock, :type => Boolean, :default => false

          self.class_eval do
            def slug= value
              super
              self.slug_lock = true
            end # method slug=
          end # class_eval
        end # if
      end # class method slugify
    end # module

    def to_slug
      raw = (self.send self.class.sluggable_options[:attribute]) || ""
      raw.gsub!(/[']/,'')
      raw.gsub!('_','-')
      raw.parameterize
    end # method to_slug
  end # module
end # module
