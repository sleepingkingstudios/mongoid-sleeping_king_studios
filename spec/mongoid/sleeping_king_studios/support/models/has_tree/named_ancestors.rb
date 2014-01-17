# spec/mongoid/sleeping_king_studios/support/models/has_tree/named_ancestors.rb

require 'mongoid/sleeping_king_studios/support/models/has_tree'

module Mongoid::SleepingKingStudios::Support::Models::HasTree
  class NamedAncestors < Mongoid::SleepingKingStudios::Support::Models::Base
    field :name, :type => String
  end # class
end # module
