require_relative '../acceptance_helper'
require_relative 'lib/login_helpers'

#happy path
describe 'User journey login_select_electorate' do
  include_context "valid login"

    it "should see the map with mesh_blocks" do
      login
      find('#electorate').find(:xpath, 'option[2]').select_option
      expect(current_url).to eq('http://localhost:4567/map?electorate=301020')
    end
end
