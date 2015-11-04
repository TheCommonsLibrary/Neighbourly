require_relative '../../spec_helper'

describe ElectorateService do

  xit 'should return electorates json' do
  	electorate_service = ElectorateService.new('Bonner')
  	expect(ElectorateService).to receive(:post).with env['ELASTIC_SEARCH_BASE_URL'], electorate_service.request_payload
  	electorate_service.get_mesh_blocks
  end
end
