# spec/mongoid/sleeping_king_studios/support/models/orderable/multi_order.rb

require 'mongoid/sleeping_king_studios/support/models/base'
require 'mongoid/sleeping_king_studios/support/models/orderable'

module Mongoid::SleepingKingStudios::Support::Models::Orderable
  class DateOrder < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::Orderable

    field :dated_at, :type => ActiveSupport::TimeWithZone

    cache_ordering :dated_at.asc, :as => :past_order,   :filter => ->() { { :dated_at.lte => Time.current } }
    cache_ordering :dated_at.asc, :as => :future_order, :filter => ->() { where(:dated_at.gte => Time.current) }
  end # class
end # module
