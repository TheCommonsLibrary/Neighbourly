require 'rack/test'
require 'rspec'
require 'sequel'
Sequel.extension :migration

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../app.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c|
	c.include RSpecMixin 
  db = test_db_connection
	c.add_setting :db, default: db
  c.before(:suite) do
    Sequel::Migrator.apply(db, './migrations')
  end
  c.after(:suite) do
    Sequel::Migrator.apply(db, './migrations', 0)
  end
}
