
#happy path
describe 'Login Feature' do  
  context 'the login URL' do

    # before (:each) do
    #   visit 'http://localhost:4567'
    # end

#sad path with invalid nation name
    it "should fail the login with valid invalid credentials" do
        visit 'http://localhost:4567'
        fill_in('nation-input', :with => 'Victoria')
        find_button('login-button').click
        expect(page).to have_content "We couldn't find the page you were looking for."
    end

#sad path with valid nation name but invalid credentials
      it "should fail the login with invalid invalid credentials" do
          visit 'http://localhost:4567'
          fill_in('nation-input', :with => 'getupstaging')
          find_button('login-button').click
          expect(current_url).to match(/https:\/\/getupstaging.nationbuilder.com/)

          find('#user_session_email').set('cherryzh@gmail.com')
          find('#user_session_password').set('123')
          first('input[name="commit"]').click
          expect(page).to have_content "1 ERROR OCCURRED WHILE PROCESSING THIS FORM."
    end

#happy path
    it "should login successfully with valid credentials" do
        visit 'http://localhost:4567'
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

