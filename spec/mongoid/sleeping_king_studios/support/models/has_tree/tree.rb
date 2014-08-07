# spec/mongoid/sleeping_king_studios/support/models/has_tree/tree.rb

require 'mongoid/sleeping_king_studios/support/models/base'
require 'mongoid/sleeping_king_studios/support/models/has_tree'

module Mongoid::SleepingKingStudios::Support::Models::HasTree
  class Tree < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::HasTree

    has_tree
  end # class
end # module
