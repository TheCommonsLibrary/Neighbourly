require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../app.rb', __FILE__
disable :run

Capybara.default_driver = :selenium

Capybara.app = Sinatra::Application
Capybara.default_wait_time = 20

RSpec.configure do |config|
  config.include Capybara::DSL
  config.add_setting :db, default: test_db_connection
end