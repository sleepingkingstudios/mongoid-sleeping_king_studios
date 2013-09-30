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

    # @api private
    # 
    # Sets up the sluggable relation, creating fields, accessors and
    # validations.
    # 
    # @param [Class] base The base class into which the concern is mixed in.
    # @param [String, Symbol] attribute The base field used to determine
    #   the value of the slug. When this field is changed via its writer
    #   method, the slug will be updated.
    # @param [Hash] options The options for the relation.
    # 
    # @since 0.6.0
    def self.apply base, attribute, options
      name = :sluggable
      validate_options    name, options
      meta = characterize name, options, Metadata
      meta[:attribute] = attribute

      relate base, name, meta

      define_fields      base, meta
      define_accessors   base, meta
      define_validations base, meta
    end # module method apply

    # @api private
    # 
    # Redefines the writer for the base attribute to overwrite the value of the
    # slug field unless the slug is locked. If the Lockable option is selected,
    # redefines the writer for the slug field to lock the slug when set
    # manually; otherwise, makes the writer for the slug field private.
    # 
    # @param [Class] base The base class into which the concern is mixed in.
    # @param [Metadata] metadata The metadata for the relation.
    # 
    # @since 0.6.0
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

    # @api private
    # 
    # Creates a slug field of type String on the base class. If the Lockable
    # option is selected, also creates a slug_lock field of type Boolean.
    # 
    # @param [Class] base The base class into which the concern is mixed in.
    # @param [Metadata] metadata The metadata for the relation.
    # 
    # @since 0.6.0
    def self.define_fields base, metadata
      base.send :field, :slug, :type => String

      if metadata.lockable?
        base.send :field, :slug_lock, :type => Boolean, :default => false
      end # if
    end # module method define_fields

    # @api private
    # 
    # Sets a validation on the slug field that validates the presence of the
    # slug, and that the value is of a valid format (lower-case characters a-z,
    # digits 0-9, and hyphens "-").
    # 
    # @param [Class] base The base class into which the concern is mixed in.
    # @param [Metadata] metadata The metadata for the relation.
    # 
    # @since 0.6.0
    def self.define_validations base, metadata
      base.validates :slug,
        :presence => true,
        :format => {
          :with => /\A[a-z0-9\-]+\z/,
          :message => 'must be lower-case characters a-z, digits 0-9, and hyphens "-"'
        } # end format
    end # module method define_validations

    # Returns a list of options that are valid for this concern.
    # 
    # @return [Array<Symbol>] The list of valid options.
    # 
    # @since 0.6.0
    def self.valid_options
      super + %i(
        lockable
      ) # end array
    end # module method valid options

    # @!attribute [r] slug
    #   A url-friendly short string version of the specified base attribute.
    #   
    #   (Lockable) The slug value can be set directly using the #slug= method.
    #   This will set the :slug_lock flag, preventing the slug from being
    #   updated by a change to the base field until :slug_lock is cleared.
    # 
    #   @return [String] The value of the stored slug.

    # @!attribute [rw] slug_lock
    #   (Lockable) A flag that indicates whether or not the slug is locked.
    #   If the flag is set, updating the base field will not change the value
    #   of the slug.
    # 
    #   @return [Boolean] True if the slug is locked; otherwise false.

    # Class methods added to the base class via #extend.
    module ClassMethods
      # @overload slugify attribute, options = {}
      #   Creates the :slug field and sets up the callback and validations.
      # 
      #   @param [String, Symbol] attribute The base field used to determine
      #     the value of the slug. When this field is changed via its writer
      #     method, the slug will be updated.
      #   @param [Hash] options The options for the relation.
      #   @option options [Boolean] :lockable
      #     The :lockable option allows the manual setting of the :slug field.
      #     To do so, it adds an additional :slug_lock field, which defaults to
      #     false but is set to true whenever #slug= is called. If the slug is
      #     locked, its value is not updated to track the base attribute. To
      #     resume tracking the base attribute, set :slug_lock to false.
      # 
      #   @raise [Mongoid::Errors::InvalidOptions] If any of the provided
      #     options are invalid.
      def slugify attribute, **options
        concern = Mongoid::SleepingKingStudios::Sluggable
        concern.apply self, attribute, options
      end # class method slugify
    end # module
  end # module
end # module
