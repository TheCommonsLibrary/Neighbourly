#happy path
describe 'Select Electorate Feature' do
  context 'the electorate selecting URL' do

    it "should see the map with mesh_blocks" do
      visit 'http://localhost:4567'
      fill_in('nation-input', :with => 'getupstaging')
      find_button('login-button').click
      expect(current_url).to match(/https:\/\/getupstaging.nationbuilder.com/)

      find('#user_session_email').set('nnguyen@thoughtworks.com')
      find('#user_session_password').set('LetMe1n')
      first('input[name="commit"]').click

      find('#electorate').find(:xpath, 'option[2]').select_option
      find_button('submit-electorate').click
      expect(current_url).to eq('http://localhost:4567/map?electorate=300989')
    end
  end
end