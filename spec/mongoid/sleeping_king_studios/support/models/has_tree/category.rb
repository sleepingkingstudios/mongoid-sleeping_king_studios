# spec/mongoid/sleeping_king_studios/support/models/has_tree/category.rb

require 'mongoid/sleeping_king_studios/support/models/has_tree'

module Mongoid::SleepingKingStudios::Support::Models::HasTree
  class Category < Mongoid::SleepingKingStudios::Support::Models::Base
    include Mongoid::SleepingKingStudios::HasTree

    field :slug, :type => String

    has_tree :cache_ancestry => { :field_name => :slug }
  end # class
end # module
