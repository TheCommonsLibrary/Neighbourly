Given(/^I open the walklist page$/) do
  visit 'http://localhost:4567'
end

When(/^I login with getupstaging$/) do
  fill_in('nation-input', :with => 'getupstaging')
  find_button('login-button').click
end

Then(/^I should be redirected to nation builder page$/) do
  expect(current_url).to have_content('https://getupstaging.nationbuilder.com')
end

