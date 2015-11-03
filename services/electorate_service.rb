require 'httparty'

class ElectorateService
  include HTTParty

  def initialize(electorate_id)
    @electorate_id = electorate_id
  end

  def request_payload
    {
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

  def get_mesh_blocks
    response = ElectorateService.get('https://site:a1534a534ef72b948437133ae441e134@kili-eu-west-1.searchly.com/_search', body: request_payload.to_json)
    response.body
  end
end
