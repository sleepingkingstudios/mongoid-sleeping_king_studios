# spec/mongoid/sleeping_king_studios/spec_helper.rb

Bundler.require # because the Gemfile specifies gems from git

require 'rspec'
require 'rspec/sleeping_king_studios'
require 'factory_girl'
require 'database_cleaner'
require 'pry'

#=# Require Factories, Custom Matchers, &c #=#
Dir[File.join __dir__, 'support', '**', '*.rb'].each { |f| require f }

root_path = __dir__.gsub /#{File.join %w(spec mongoid sleeping_king_studios)}$/, ''

require 'mongoid'

Mongoid.load!(File.join(root_path, "config", "mongoid.yml"), :test)

DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  # :focus => true
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.after :each do
    DatabaseCleaner.clean
  end # after each
end # config
