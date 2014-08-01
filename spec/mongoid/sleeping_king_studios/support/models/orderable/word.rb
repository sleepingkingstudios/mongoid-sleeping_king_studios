# spec/mongoid/sleeping_king_studios/support/models/orderable/word.rb 

require 'mongoid/sleeping_king_studios/support/models/orderable'

module Mongoid::SleepingKingStudios::Support::Models::Orderable
  class Word < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::Orderable

    field :letters, :type => String

    cache_ordering :letters, :as => :alphabetical_order,
      :filter => { :letters.ne => nil }
  end # class
end # module
