# spec/mongoid/sleeping_king_studios/support/models/has_tree/part.rb

require 'mongoid/sleeping_king_studios/support/models/has_tree'

module Mongoid::SleepingKingStudios::Support::Models::HasTree
  class Part < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::HasTree

    has_tree :parent => { :relation_name => :container },
      :children => { :relation_name => :subcomponent },
      :cache_ancestry => { :relation_name => :assemblies }
  end # class
end # module
