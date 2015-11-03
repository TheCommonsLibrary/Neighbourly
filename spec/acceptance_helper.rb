require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../app.rb', __FILE__
disable :run

Capybara.default_driver = :selenium

Capybara.app = Sinatra::Application

RSpec.configure do |config|
  config.include Capybara
  config.include Capybara::DSL
end