require_relative './mesh_block_query'
require_relative './../models/mesh_blocks_claim'
require_relative './elastic_search_gateway'

class ElectorateService

  def initialize(electorate_id, db)
    @db = db
    @mesh_block_query = MeshBlocksQuery.new electorate_id
  end

  def get_mesh_blocks(nation_slug)
    parsed_response = @mesh_block_query.execute
    elastic_search_gateway = ElasticSearchGateway.new(parsed_response, nation_slug)

    if parsed_response.include?("error")
      {}
    else
      mesh_blocks = parsed_response['hits']['hits']
      claim = MeshBlockClaim.new(@db, mesh_blocks)
      mesh_block_claimers = claim.get_claimers
      elastic_search_gateway.format_meshblocks(mesh_block_claimers)
    end
  end
end
