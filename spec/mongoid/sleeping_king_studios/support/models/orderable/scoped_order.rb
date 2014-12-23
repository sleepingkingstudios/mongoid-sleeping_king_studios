# spec/mongoid/sleeping_king_studios/support/models/orderable/scoped_order.rb

require 'mongoid/sleeping_king_studios/support/models/base'
require 'mongoid/sleeping_king_studios/support/models/orderable'

module Mongoid::SleepingKingStudios::Support::Models::Orderable
  class ScopedOrder < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::Orderable

    field :category, :type => String
    field :value,    :type => Integer

    cache_ordering :value, :filter => { :category.ne => nil }, :scope => :category
  end # class
end # module
