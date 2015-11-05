require_relative '../acceptance_helper'
require_relative 'lib/login_helpers'
require_relative '../acceptance/lib/clear_cookies'


describe 'select a block' do
  include_context "valid login"

  it 'should display the appropriate color and text ' do
    login
    expect(current_url).to eq('http://localhost:4567/map')
    select 'Batman', from: "electorate"
    find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(6)').hover
    expect(find('.info .text').text).to eq("No one will door knock this area. Click if you want to walk it.")

    # click and see the meshblock change color
    find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(6)').click
    expect(find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(7)')['#DDA0DD']) == true

    # hover the area already selected and see the message
    find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(5)').hover
    find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(6)').hover
    expect(find('.info .text').text).to eq("You will door knock this area. Click if you no longer want to door knock the area.")

    # unselected the meshblock
    find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(6)').click
    expect(find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(7)')['#E6FF00']) == true
  end
end





