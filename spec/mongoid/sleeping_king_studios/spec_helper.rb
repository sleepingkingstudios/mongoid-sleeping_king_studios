# spec/mongoid/sleeping_king_studios/spec_helper.rb

require 'bundler'
Bundler.require # because the Gemfile specifies gems from git

# Silence deprecation warning from I18n.
I18n.enforce_available_locales = true

require 'rspec'
require 'rspec/sleeping_king_studios'
require 'factory_girl'
require 'database_cleaner'
require 'pry'

### Require Factories, Custom Matchers, &c ###
Dir[File.join __dir__, *%w(support ** *.rb)].each { |f| require f }

root_path = __dir__.gsub /#{File.join %w(spec mongoid sleeping_king_studios)}$/, ''

require 'mongoid'

Mongoid.load!(File.join(root_path, "config", "mongoid.yml"), :test)

RSpec.configure do |config|
  # Limit a spec run to individual examples or groups you care about by tagging
  # them with `:focus` metadata.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Allow more verbose output when running an individual spec file.
  config.default_formatter = 'doc' if config.files_to_run.one?

  # Run specs in random order to surface order dependencies.
  config.order = :random
  Kernel.srand config.seed

  # Alias "it should behave like" to 2.13-like syntax.
  config.alias_it_should_behave_like_to 'expect_behavior', 'has behavior'

  # rspec-expectations config goes here.
  config.expect_with :rspec do |expectations|
    # Enable only the newer, non-monkey-patching expect syntax.
    expectations.syntax = :expect
  end # expect_with

  # rspec-mocks config goes here.
  config.mock_with :rspec do |mocks|
    # Enable only the newer, non-monkey-patching expect syntax.
    mocks.syntax = :expect

    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended.
    mocks.verify_partial_doubles = true
  end # mock_with

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end # before suite

  config.after(:each) do
    DatabaseCleaner.clean
  end # after each
end # config
