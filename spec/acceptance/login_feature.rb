require_relative 'lib/login_helpers'

describe 'Login' do

	describe 'New User' do

		it 'should redirect to user detail page to collect user information' do
			visit 'http://localhost:8080'
			fill_in('login-input', :with => 'newuser@test.com')
			find_button('login-button').click
			expect(current_url).to eq("http://localhost:8080/user_details?email=newuser@test.com")

			expect(page).to have_selector("input[name='user_details[email]']")
			expect(page).to have_selector("input[name='user_details[name]']")
			expect(page).to have_selector("input[name='user_details[organisation]']")
			expect(page).to have_selector("input[name='user_details[phone]']")
			
			expect(find("input[name='user_details[email]']").value).to eq 'newuser@test.com'
		end

		it 'should redirect to /map after collect user information' do
			visit 'http://localhost:8080'
			fill_in('login-input', :with => 'createuser@test.com')
			find_button('login-button').click
			find_button('login-button').click

			expect(current_url).to eq("http://localhost:8080/map")
			click_link('logout')
		end

	end

	describe 'Exisit User' do
		include_context "valid login"
		it 'should redirect to /map' do
			login
			expect(current_url).to eq("http://localhost:8080/map")
			click_link('logout')
		end
	end
	
end