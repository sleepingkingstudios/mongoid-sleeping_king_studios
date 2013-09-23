# lib/mongoid/sleeping_king_studios/sluggable.rb

require 'mongoid/sleeping_king_studios/concern'
require 'mongoid/sleeping_king_studios/sluggable/metadata'

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
    extend Mongoid::SleepingKingStudios::Concern

    def self.characterize name, options
      Metadata.new name, options
    end # module method characterize

    def self.define_accessors base, metadata
      base.re_define_method :"#{metadata.attribute}=" do |value|
        self[metadata.attribute.to_s] = value
        unless metadata.lockable? && self['slug_lock']
          self['slug'] = metadata.value_to_slug value
        end # unless
      end # method

      if metadata.lockable?
        base.re_define_method :slug= do |value|
          self['slug'] = value
          self['slug_lock'] = true
        end # method
      else
        base.send :private, :slug=
      end # if
    end # module method define_accessors

    def self.define_fields base, metadata
      base.send :field, :slug, :type => String

      if metadata.lockable?
        base.send :field, :slug_lock, :type => Boolean, :default => false
      end # if
    end # module method define_fields

    def self.define_validations base, metadata
      base.validates :slug,
        :presence => true,
        :format => {
          :with => /\A[a-z0-9\-]+\z/,
          :message => 'must be lower-case characters a-z, digits 0-9, and hyphens "-"'
        } # end format
    end # module method define_validations

    def self.valid_options
      super + %i(
        lockable
      ) # end array
    end # module method valid options

    # @!attribute [r] slug
    #   A url-friendly short string version of the specified base attribute.
    #   Read-only unless the :lockable option is selected.
    # 
    #   @return [String] the slug value

    # Class methods added to the base class via #extend.
    module ClassMethods
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
        concern = Mongoid::SleepingKingStudios::Sluggable
        concern.validate_options attribute, options

        meta    = concern.characterize :sluggable, options
        meta[:attribute] = attribute

        concern.relate self, :sluggable, meta

        concern.define_fields      self, meta
        concern.define_accessors   self, meta
        concern.define_validations self, meta
      end # class method slugify
    end # module
  end # module
end # module
