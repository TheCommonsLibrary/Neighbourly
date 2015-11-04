require 'httparty'

class ElectorateService
  #include HTTParty

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

  def get_mesh_blocks(db)
    response = HTTParty.get(@elastic_search_url + '/_search', body: request_payload.to_json)
    parsed_response = JSON.parse(response.body)
    if parsed_response.include?("error")
      {}
    else
      mesh_blocks = JSON.parse(response.body)['hits']['hits']
      
      mesh_block_claimers = db[:mesh_block_claims].
        where(mesh_block_slug: mesh_block_query(mesh_blocks)).
        where("claim_date > now() - INTERVAL '2 weeks'").
        select(:mesh_block_claimer, :mesh_block_slug).
        map { |row| 
          [ row[:mesh_block_slug], row[:mesh_block_claimer] ]
        }.to_h

      format_meshblocks(mesh_blocks, mesh_block_claimers)
    end
  end

  private

  def mesh_block_query(mesh_blocks)
    mesh_blocks.map { |mesh_block| mesh_block['_source']['slug'] }
  end

  def format_meshblocks(mesh_blocks, mesh_block_claimers)
    mesh_blocks.map do |mesh_block|
      {
        type: 'Feature',
        geometry: mesh_block['_source']['location'],
        properties: {
          slug: mesh_block['_source']['slug'],
          type: mesh_block['_source']['type'],
          claimBy: mesh_block_claimers[mesh_block['_source']['slug']],
        }
      }
    end
  end
end
