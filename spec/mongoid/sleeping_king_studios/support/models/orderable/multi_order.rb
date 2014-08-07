# spec/mongoid/sleeping_king_studios/support/models/orderable/multi_order.rb 

require 'mongoid/sleeping_king_studios/support/models/base'
require 'mongoid/sleeping_king_studios/support/models/orderable'

module Mongoid::SleepingKingStudios::Support::Models::Orderable
  class MultiOrder < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::Orderable

    field :primary,   :type => Integer
    field :secondary, :type => Integer

    cache_ordering :primary, :secondary.desc
  end # class
end # module
