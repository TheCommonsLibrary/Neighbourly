require 'capybara'
require 'capybara/cucumber'

require_relative '../../app.rb'

Capybara.app = Sinatra::Application