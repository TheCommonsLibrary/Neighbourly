require_relative '../acceptance_helper'
require_relative 'lib/login_helpers'
require_relative '../acceptance/lib/clear_cookies'

describe 'login_navigate_map' do
  include_context "valid login"

  it 'should see the navigation_map page' do
    login
    expect(current_url).to eq('http://localhost:4567/map')
  end
end

