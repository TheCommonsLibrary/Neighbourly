require_relative 'lib/login_helpers'

describe 'download' do
	include_context "valid login"

	it 'should redirect to download page' do
		login
		find('.download').click
		expect(current_url).to eq("http://localhost:8080/download")
		expect(page).to have_content("Previously Selected Walkpaths")
		click_link('logout')
	end

	it 'should download one file' do
		login
		select 'Reid', from: "electorate"
		find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(1)').click
		find('.download').click
		expect(page).to have_content("Newly Selected Walkpaths")
		expect(page).to have_css('div.button.button-primary.download-all')
		expect(page).to have_css('div.button.button-primary.claim-all')
		expect(page).to have_content("_walklist.pdf")

		find('.claim').click
		expect(page.all('.claim').count).to eq(0)
	end


end