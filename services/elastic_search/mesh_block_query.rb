require_relative './connection'

module ElasticSearch
  module Query
    class MeshBlocksQuery
      
      def initialize(electorate_id, elastic_search_connection)
        @elastic_search_connection = elastic_search_connection
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
                  "_cache": true,
                  "location": {
                    "relation": "within",
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
        @elastic_search_connection.execute @query
      end
    end
  end
end
