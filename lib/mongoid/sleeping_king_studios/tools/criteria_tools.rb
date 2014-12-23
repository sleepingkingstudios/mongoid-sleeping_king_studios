# lib/mongoid/sleeping_king_studios/tools/criteria_tools.rb

require 'mongoid/sleeping_king_studios/tools'

module Mongoid::SleepingKingStudios::Tools
  module CriteriaTools
    extend self

    def union source, target
      source, target = source.to_criteria.clone, target.to_criteria.clone

      selector = target.selector
      source.selector.each do |key, value|
        if !selector.key?(key)
          selector[key] = value
        elsif selector[key].is_a?(Hash) && value.is_a?(Hash)
          selector[key].merge! value
        else
          selector['$and'] ||= []
          selector['$and'] << { key => selector[key] }
          selector['$and'] << { key => value }
          selector.delete key
        end # if
      end # each

      source.selector.clear

      target.merge!(source)
    end # method union
  end # module
end # module
