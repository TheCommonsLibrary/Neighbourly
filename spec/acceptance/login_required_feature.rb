describe 'Login Feature' do  
  context 'the login URL' do
    before :each do
      visit 'http://localhost:4567'
    end

    it "should login successfully with valid credentials" do
        fill_in('nation-input', :with => 'getupstaging')
        find_button('login-button').click
        expect(current_url).to match(/https:\/\/getupstaging.nationbuilder.com/)

        find('#user_session_email').set('ili@thoughtworks.com')
        find('#user_session_password').set('11qazwsxedc')
        first('input[name="commit"]').click
        expect(current_url).to eq('http://localhost:4567/electorates')
    end
  end
end