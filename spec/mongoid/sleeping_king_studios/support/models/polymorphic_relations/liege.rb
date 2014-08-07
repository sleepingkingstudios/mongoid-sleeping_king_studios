# spec/mongoid/sleeping_king_studios/support/models/polymorphic_relations/liege.rb

require 'mongoid/sleeping_king_studios/support/models/base'
require 'mongoid/sleeping_king_studios/support/models/polymorphic_relations'

module Mongoid::SleepingKingStudios::Support::Models::PolymorphicRelations
  class Liege < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::PolymorphicRelations

    has_many :vassals

    polymorphic_relation :knights, :vassals
  end # class
end # module
