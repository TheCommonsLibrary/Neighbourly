require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'

shared_context "valid login" do
  def login
    visit 'http://localhost:4567'
    fill_in('nation-input', :with => 'getupstaging')
    find_button('login-button').click
    #expect(current_url).to match(/https:\/\/getupstaging.nationbuilder.com/)

    #find('#user_session_email').set('ili@thoughtworks.com')
    #find('#user_session_password').set('11qazwsxedc')
    #first('input[name="commit"]').click
    expect(current_url).to eq('http://localhost:4567/electorates')
  end


  after(:each) {
    puts "Clearing cookies"
    Capybara.reset_sessions!
    Capybara.current_session.driver.browser.manage.delete_all_cookies
  }
end