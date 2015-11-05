require_relative '../acceptance_helper'
require_relative '../acceptance/lib/clear_cookies'
require_relative 'lib/login_helpers'

describe 'Login' do

  describe 'should failed' do
    after :each do
      Capybara.reset_sessions!
    end

    it "with invalid nation slug" do
        visit 'http://localhost:4567'
        fill_in('nation-input', :with => 'Victoria')
        find_button('login-button').click
        expect(page).to have_content "We couldn't find the page you were looking for."
    end

    it "with invalid credentials" do
        visit 'http://localhost:4567'
        fill_in('nation-input', :with => 'getupstaging')
        find_button('login-button').click
        expect(current_url).to match(/https:\/\/getupstaging.nationbuilder.com/)

        find('#user_session_email').set('invalid@test.com')
        find('#user_session_password').set('invalid')
        first('input[name="commit"]').click
        expect(page).to have_content "1 ERROR OCCURRED WHILE PROCESSING THIS FORM."
    end
  end

  describe 'should redirect to login page without authentication' do
    it "from /map" do
        visit 'http://localhost:4567/map'
        expect(page).to have_content "You need to login before you can view that page."
    end

    it "from /electorates" do
        visit 'http://localhost:4567/electorates'
        expect(page).to have_content "You need to login before you can view that page."
    end
  end

  describe 'with credentials' do
    include_context "valid login"

    it "should login successfully with valid credentials" do
      visit 'http://localhost:4567'
      fill_in('nation-input', :with => 'getupstaging')
      find_button('login-button').click
      expect(current_url).to match(/https:\/\/getupstaging.nationbuilder.com/)

      find('#user_session_email').set('ili@thoughtworks.com')
      find('#user_session_password').set('11qazwsxedc')
      first('input[name="commit"]').click
      expect(current_url).to eq('http://localhost:4567/map')
    end
  end
end
