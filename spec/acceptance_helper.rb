require File.expand_path '../../app.rb', __FILE__
disable :run

require 'capybara'
require 'capybara/dsl'
#require_relative 'spec_heler'

Capybara.app = Sinatra::Application

RSpec.configure do |config|
  config.include Capybara
end