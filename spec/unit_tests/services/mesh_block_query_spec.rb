require_relative '../../../services/elastic_search/mesh_block_query'

describe 'MeshBlockQuery' do

	before :each do
		@query = {
      "from": 0,
      "size": 3000,
      "query": {
        "filtered": {
          "query": {
            "match": {
              "type": "MeshBlock"
            }
          },
          "filter": {
            "geo_shape": {
              "_cache": true,
              "location": {
                "relation": "within",
                  "indexed_shape": {
                  "id": 1,
                  "index": "territories",
                  "type": "territory",
                  "path": "location"
                }
              }
            }
          }
        }
      }
    }
	end
	
	describe '#execute' do
		it 'should successfully get response from elastic search' do
			elastic_search_connection = double('elastic_search_connection')
			expect(elastic_search_connection).to receive(:execute).with(@query)
			mesh_block_query = ElasticSearch::Query::MeshBlocksQuery.new 1, elastic_search_connection
			mesh_block_query.execute
		end
	end

end
