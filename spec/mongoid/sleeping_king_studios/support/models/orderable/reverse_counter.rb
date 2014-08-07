# spec/mongoid/sleeping_king_studios/support/models/orderable/reverse_counter.rb

require 'mongoid/sleeping_king_studios/support/models/base'
require 'mongoid/sleeping_king_studios/support/models/orderable'

module Mongoid::SleepingKingStudios::Support::Models::Orderable
  class ReverseCounter < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::Orderable

    field :value, :type => Integer

    cache_ordering :value.desc
  end # class
end # module
