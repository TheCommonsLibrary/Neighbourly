require_relative './mesh_block_query'
require_relative './../models/mesh_blocks_claim'
require_relative './elastic_search_gateway'

class ElectorateService
  def initialize(electorate_id, db)
    @db = db
    @mesh_block_query = MeshBlocksQuery.new electorate_id
  end

  def get_mesh_blocks(nation_slug)
    results = @mesh_block_query.execute
    elastic_search_gateway = ElasticSearchGateway.new(results, nation_slug)
    claim = MeshBlockClaim.new(@db, results['hits']['hits'])
    elastic_search_gateway.format_meshblocks claim.get_claimers
  end
end
