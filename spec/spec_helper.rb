ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'database_cleaner'
include Messenger 
include FakeSMS
#require 'rspec/autorun'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:each) do
    stub_const('Messenger', 'FakeSMS')
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation

  # then, whenever you need to clean the DB
    DatabaseCleaner.clean
    #DatabaseCleaner.clean_with(:truncation)
  end

end

