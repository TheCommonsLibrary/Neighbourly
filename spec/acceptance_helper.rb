require 'capybara'
require 'capybara/dsl'

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../app.rb', __FILE__
disable :run

Capybara.default_driver = :selenium

Capybara.app = Sinatra::Application

RSpec.configure do |config|
  config.include Capybara
end