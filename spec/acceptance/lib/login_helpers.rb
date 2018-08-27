require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'

#TODO - MONDAY FIX TESTS!
#	modified:   spec/acceptance/download_feature.rb
#	modified:   spec/acceptance/lib/login_helpers.rb
#	modified:   spec/acceptance/login_feature.rb

shared_context "valid login" do
  before(:all) {
    @db = RSpec.configuration.db
    @db[:users].insert(:email => 'existuser@test.com', :first_name => 'Exist', \
    :last_name => 'User', :postcode => '2042', \
    :phone => '123', :created_at => Time.now)
  }

  def login
    visit 'http://localhost:8080'
    fill_in('login-input', :with => 'existuser@test.com')
    find_button('login-button').click
  end

  after(:all) {
    @db[:users].delete
    @db[:claims].delete
  }
end
