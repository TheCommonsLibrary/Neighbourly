require_relative 'lib/login_helpers'

describe 'happy_path' do
	include_context "valid login"

	it 'should allow a download on an unclaimed meshblock and show unclaim button' do
		login
		find('.ui-dialog-titlebar-close').click
		fill_in('address_search', :with => '2042')
    find_button('address_search_button').click
		find('#map > div.leaflet-map-pane > div.leaflet-objects-pane > div.leaflet-overlay-pane > svg > g:nth-child(162) > path').click
		find('#map > div.leaflet-map-pane > div.leaflet-objects-pane > div.leaflet-popup-pane > div > div.leaflet-popup-content-wrapper > div > div > div.popupgrp.claim > div.popupbutton.btnclaim > button').click
		expect(page).to have_content('Unclaim')
		
	end

end
