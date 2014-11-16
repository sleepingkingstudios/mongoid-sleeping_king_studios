# lib/mongoid/sleeping_king_studios.rb

require 'mongoid'

module Mongoid
  # A collection of concerns and extensions to add functionality to Mongoid
  # documents and collections.
  module SleepingKingStudios
    def self.root
      Pathname.new File.join __dir__, 'sleeping_king_studios'
    end # class method root
  end # module
end # module

### Require Extensions ###
Dir[File.join Mongoid::SleepingKingStudios.root, *%w(ext ** *.rb)].each { |f| require f }
