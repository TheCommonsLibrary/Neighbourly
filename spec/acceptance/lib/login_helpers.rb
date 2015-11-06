require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'

shared_context "valid login" do
  before(:all) {
    @db = RSpec.configuration.db
    @db[:users].insert(:email => 'existuser@test.com', :name => 'Exist User', :organisation => 'Test', :phone => '123', :created_at => Time.now)
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