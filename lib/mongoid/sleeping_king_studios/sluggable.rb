# lib/mongoid/sleeping_king_studios/sluggable.rb

require 'mongoid/sleeping_king_studios'

module Mongoid::SleepingKingStudios
  # Adds a :slug field that stores a short, url-friendly reference string,
  # useful for human-readable urls. By default, the slug field is
  # automatically overwritten from the specified base attribute before
  # validation. To enable setting the slug manually, use the :lockable
  # option; otherwise, the :slug= writer is set to private.
  # 
  # @example Setting up the slug:
  #   class SluggableDocument
  #     include Mongoid::Document
  #     include Mongoid::SleepingKingStudios::Sluggable
  #
  #     field :title, :type => String
  #
  #     slugify :title
  #   end # class
  # 
  # @see ClassMethods#slugify
  # 
  # @since 0.1.0
  module Sluggable
    extend ActiveSupport::Concern

    # @!attribute [r] slug
    #   A url-friendly short string version of the specified base attribute.
    #   Read-only unless the :lockable option is selected.
    # 
    #   @return [String] the slug value

    # Class methods added to the base class via #extend.
    module ClassMethods
      # Returns the options passed into ::slugify, as well as an additional
      # :attribute value for the attribute passed into ::slugify.
      attr_reader :sluggable_options

      # @overload slugify attribute, options = {}
      #   Creates the :slug field and sets up the callback and validations.
      # 
      #   @param [String, Symbol] attribute
      #   @option options [Boolean] :lockable
      #     The :lockable option allows the manual setting of the :slug field.
      #     To do so, it adds an additional :slug_lock field, which defaults to
      #     false but is set to true whenever #slug= is called. If the slug is
      #     locked, its value is not updated to track the base attribute. To
      #     resume tracking the base attribute, set :slug_lock to false.
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
          self[:slug] = to_slug
        end # before validation callback

        # Lockable
        if options.fetch(:lockable, false)
          field :slug_lock, :type => Boolean, :default => false

          self.class_eval do
            def slug= value
              super
              self.slug_lock = true
            end # method slug=
          end # class eval
        else
          private :slug=
        end # if
      end # class method slugify
    end # module

    # Processes the specified base attribute and returns a valid slug value. By
    # default, calls String#parameterize.
    # 
    # @return [String] the processed value
    def to_slug
      raw = (self.send self.class.sluggable_options[:attribute]) || ""
      raw.parameterize
    end # method to_slug
  end # module
end # module
