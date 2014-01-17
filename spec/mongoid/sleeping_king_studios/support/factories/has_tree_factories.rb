# spec/mongoid/sleeping_king_studios/support/factories/has_tree_factories.rb

require 'mongoid/sleeping_king_studios/support/models/has_tree/category'
require 'mongoid/sleeping_king_studios/support/models/has_tree/directory'
require 'mongoid/sleeping_king_studios/support/models/has_tree/named_ancestors'
require 'mongoid/sleeping_king_studios/support/models/has_tree/part'

FactoryGirl.define do
  namespace = Mongoid::SleepingKingStudios::Support::Models::HasTree

  factory :category, :class => namespace::Category do
    sequence(:slug) { |index| "category-#{index}" }
  end # factory

  factory :directory, :class => namespace::Directory do

  end # factory

  factory :named_ancestors, :class => namespace::NamedAncestors do
    sequence(:name) { |index| "Named #{index}" }
  end # factory

  factory :part, :class => namespace::Part do

  end # factory
end # define
