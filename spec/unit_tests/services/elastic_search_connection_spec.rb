require_relative '../../../services/elastic_search/connection'

describe 'ElasticSearchConnection' do

	describe '#execute' do
		before :each do
			ENV['ELASTIC_SEARCH_BASE_URL'] = 'elastic-search-url'	
			@response = double('response', body: "{}")
			@elastic_search_connection = ElasticSearch::Connection.new

		end
		
		it 'should connect to elastic search use url from env' do
			query = {key: 'value'}
			expect(HTTParty).to receive(:get).with('elastic-search-url/_search', body: "{\"key\":\"value\"}").and_return(@response)
		    @elastic_search_connection.execute query
		end

		it 'should json parse the elastic search response body' do
			allow(HTTParty).to receive(:get).with(any_args).and_return(@response)
			expect(JSON).to receive(:parse).with "{}"
			@elastic_search_connection.execute ""
		end
	end
end