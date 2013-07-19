# spec/mongoid/sleeping_king_studios/spec_helper.rb

require 'rspec'
require 'factory_girl'
require 'database_cleaner'
require 'pry'

#=# Require Factories, Custom Matchers, &c #=#
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.color_enabled = true

  config.after :each do
    DatabaseCleaner.clean
  end # after each
end # config
