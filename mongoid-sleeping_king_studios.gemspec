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
  
  gem.add_runtime_dependency 'mongoid',  '>= 4.0.0.alpha.1'
  gem.add_runtime_dependency 'bson_ext', '~> 1.9.0'
  gem.add_runtime_dependency 'sleeping_king_studios-ext', '~> 0.1'
  
  gem.add_development_dependency 'rspec',                       '~> 2.14'
  gem.add_development_dependency 'rspec-sleeping_king_studios', '~> 1.0'
  gem.add_development_dependency 'factory_girl',                '~> 4.2'
  gem.add_development_dependency 'database_cleaner',            '~> 1.0.1'
  gem.add_development_dependency 'fuubar',                      '~> 1.2'
  gem.add_development_dependency 'pry',                         '~> 0.9'
end # gemspec
