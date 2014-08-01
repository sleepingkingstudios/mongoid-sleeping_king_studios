# spec/mongoid/sleeping_king_studios/support/models/orderable/counter.rb

require 'mongoid/sleeping_king_studios/support/models/orderable'

module Mongoid::SleepingKingStudios::Support::Models::Orderable
  class Counter < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::Orderable

    field :value, :type => Integer

    cache_ordering :value
  end # class
end # module
