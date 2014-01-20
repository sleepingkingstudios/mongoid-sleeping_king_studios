# spec/mongoid/sleeping_king_studios/support/models/orderable/date_order.rb

require 'mongoid/sleeping_king_studios/support/models/orderable'

module Mongoid::SleepingKingStudios::Support::Models::Orderable
  class DateOrder < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::Orderable

    field :date, :type => DateTime

    cache_ordering :date, :order_nil? => true
  end # class
end # module
