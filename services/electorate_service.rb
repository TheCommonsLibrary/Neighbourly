require 'httparty'

class ElectorateService
  include HTTParty

  def initialize(electorate_id)
    @electorate_id = electorate_id
    @elastic_search_url = ENV['ELASTIC_SEARCH_BASE_URL'] 
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
    response = ElectorateService.get(@elastic_search_url + '/_search', body: request_payload.to_json)
    @mesh_blocks = JSON.parse(response.body)['hits']['hits']
    get_feature_collection_from_mesh_blocks
  end

  private
  def get_feature_collection_from_mesh_blocks
    feature_collection = []
    @mesh_blocks.map do |mesh_block|
      feature = {type: 'Feature'}
      feature[:geometry] = mesh_block['_source']['location']
      feature[:properties] = {}
      feature_collection << feature
    end
    feature_collection
  end
end
