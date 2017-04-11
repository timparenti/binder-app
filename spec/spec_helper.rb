ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec'
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

  config.expect_with(:rspec) { |c| c.syntax = :should }
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.around(:each, :delayed_job) do |example|
    old_value = Delayed::Worker.delay_jobs
    Delayed::Worker.delay_jobs = true
    Delayed::Job.destroy_all

    example.run

    Delayed::Worker.delay_jobs = old_value
  end

  #this should be calling FakeSMS module everytime Messenger is called in the model (when doing the notification)

  config.before(:each) do
    stub_const('Messenger', 'lib/FakeSMS.rb')
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation

  # then, whenever you need to clean the DB
    DatabaseCleaner.clean
    #DatabaseCleaner.clean_with(:truncation)
  end

end

