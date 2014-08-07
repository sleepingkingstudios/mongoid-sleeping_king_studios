# spec/mongoid/sleeping_king_studios/support/models/polymorphic_relations/vassal.rb

require 'mongoid/sleeping_king_studios/support/models/base'

module Mongoid::SleepingKingStudios::Support::Models::PolymorphicRelations
  class Vassal < Mongoid::SleepingKingStudios::Support::Models::Base
    belongs_to :liege
  end # class
end # module
