require_relative 'lib/login_helpers'

describe 'Logout Feature' do
  include_context "valid login"

    it 'should show logout message after user logout' do
      login

      click_link('logout')

      expect(page).to have_content('You have been logged out.')
    end

    it 'user has to login again after log out' do
      login

      click_link('logout')

      visit 'http://localhost:8080/map'

      expect(current_url).to eq("http://localhost:8080/")
    end
end