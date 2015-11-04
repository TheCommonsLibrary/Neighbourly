require_relative './elastic_search/connection'

class MeshBlocksQuery
  
  def initialize(electorate_id)
  	@elastic_search = ElasticSearch::Connection.new
  	@electorate_id = electorate_id
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
              "location": {
                "indexed_shape": {
                  "id": @electorate_id,
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

  def execute
  	@elastic_search.execute @query
  end
end
