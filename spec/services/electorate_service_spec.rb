require_relative '../spec_helper'

describe ElectorateService do

  it 'should return electorates json' do
  	elastic_search_url = 'https://site:a1534a534ef72b948437133ae441e134@kili-eu-west-1.searchly.com/_search'
  	electorate_service = ElectorateService.new('Bonner')

  	expect(ElectorateService).to receive(:post).with elastic_search_url, electorate_service.request_payload

  	electorate_service.get_mesh_blocks
  end

end