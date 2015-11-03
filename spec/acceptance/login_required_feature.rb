
#happy path
describe 'Login Feature' do 

  describe 'without credentials' do
  
    it "should fail the login with valid invalid credentials" do
        visit 'http://localhost:4567'
        fill_in('nation-input', :with => 'Victoria')
        find_button('login-button').click
        expect(page).to have_content "We couldn't find the page you were looking for."
    end

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
    
    it "should redirect to login page" do
        visit 'http://localhost:4567/map'
        expect(page).to have_content "You need to login before you can view that page."
    end
  end
end
  
