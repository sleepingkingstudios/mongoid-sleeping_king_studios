# spec/mongoid/sleeping_king_studios/support/models/sluggable/lock.rb

require 'mongoid/sleeping_king_studios/support/models/base'
require 'mongoid/sleeping_king_studios/support/models/sluggable'

module Mongoid::SleepingKingStudios::Support::Models::Sluggable
  class Lock < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::Sluggable

    field :name, :type => String

    slugify :name, :lockable => true
  end # class
end # module
