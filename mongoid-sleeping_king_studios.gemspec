# mongoid-sleeping_king_studios.gemspec

require File.expand_path "lib/mongoid/sleeping_king_studios/version"

Gem::Specification.new do |gem|
  gem.name        = 'mongoid-sleeping_king_studios'
  gem.version     = Mongoid::SleepingKingStudios::VERSION
  gem.date        = '2013-07-19'
  gem.summary     = 'A collection of Mongoid concerns and extensions.'
  gem.description = <<-DESCRIPTION
    A collection of concerns and extensions to add functionality to Mongoid
    documents and collections. The features can be included individually or by
    category. For more information, check out the README.
  DESCRIPTION
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'
  
  gem.require_path = 'lib'
  gem.files        = Dir["lib/**/*.rb", "LICENSE", "*.md"]
  
  gem.add_runtime_dependency 'mongoid',  '~> 4.0'
  gem.add_runtime_dependency 'sleeping_king_studios-ext', '~> 0.2'
  
  gem.add_development_dependency 'rspec',                       '~> 3.0'
  gem.add_development_dependency 'rspec-sleeping_king_studios', '~> 2.0.0.beta.0'
  gem.add_development_dependency 'factory_girl',                '~> 4.4'
  gem.add_development_dependency 'database_cleaner',            '~> 1.3'
  gem.add_development_dependency 'pry',                         '~> 0.10'
end # gemspec
