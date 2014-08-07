# spec/mongoid/sleeping_king_studios/support/models/sluggable/slug.rb

require 'mongoid/sleeping_king_studios/support/models/base'
require 'mongoid/sleeping_king_studios/support/models/sluggable'

module Mongoid::SleepingKingStudios::Support::Models::Sluggable
  class Slug < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::Sluggable

    field :name, :type => String

    slugify :name
  end # class
end # module
