require_relative 'lib/login_helpers'

describe 'Map Feature' do
  include_context "valid login"

  before (:each) do
    login
    select 'Batman', from: "electorate"
  end

  describe 'Mesh Block color' do

    it 'should be green when unclaimed' do
      find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(1)').hover
      expect(find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(1) path')[:fill]).to eq ('#E6FF00')
    end

    it 'should be pink when selected' do
      find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(1)').click
      expect(find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(1) path')[:fill]).to eq ('#DDA0DD')
    end

  end

  describe 'Hint message' do

    it 'should change when hover unclaimed mesh block' do
      find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(1)').hover
      expect(page).to have_content("No one will door knock this area. Click if you want to door knock it.")
    end

    it 'should change after select mesh block' do
      find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(1)').click
      find('#logo-image').hover
      find('#map .leaflet-map-pane .leaflet-overlay-pane svg g:nth-child(1)').hover
      expect(page).to have_content("You will door knock this area. Click if you no longer want to door knock the area.")
    end

  end
  
  after (:each) do
    click_link('logout')
  end

end