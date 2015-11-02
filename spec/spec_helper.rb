require 'rack/test'
require 'rspec'

require File.expand_path '../../app.rb', __FILE__
require File.expand_path '../../services/electorate_service.rb', __FILE__

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../app.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }
