# spec/mongoid/sleeping_king_studios/support/models/has_tree/villain.rb

require 'mongoid/sleeping_king_studios/support/models/has_tree'

module Mongoid::SleepingKingStudios::Support::Models::HasTree
  class Villain < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::HasTree

    has_tree :parent => { :relation_name => :overlord },
      :children => { :relation_name => :minions, :dependent => :destroy }
  end # class
end # module
