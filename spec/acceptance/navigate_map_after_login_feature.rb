require_relative '../acceptance_helper'
require_relative 'lib/login_helpers'
require_relative '../acceptance/lib/clear_cookies'


describe 'choose electorate' do
  include_context "valid login"

  it 'should see map and map should be updated after I choose a electorate' do
    login
    expect(current_url).to eq('http://localhost:4567/map')
    select 'Batman', from: "electorate"
    find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(1)').hover
    expect(find('.info .text').text).to eq("No one will door knock this area. Click if you want to walk it.")
    sleep 3
    puts "HERE"
  
  end
end





