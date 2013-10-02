# spec/mongoid/sleeping_king_studios/support/models/has_tree/directory.rb

require 'mongoid/sleeping_king_studios/support/models/has_tree'

module Mongoid::SleepingKingStudios::Support::Models::HasTree
  class Directory < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::HasTree

    has_tree :cache_ancestry => true
  end # class
end # module
