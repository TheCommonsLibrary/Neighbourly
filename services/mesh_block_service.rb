require_relative './mesh_block_query'
require_relative './../models/mesh_blocks_claim'
require_relative './../models/feature_collection'

class MeshBlockService
  def initialize(electorate_id, db, nation_slug)
    @query_results = MeshBlocksQuery.new(electorate_id).execute
    claim = MeshBlockClaim.new(db, @query_results['hits']['hits'])
    @feature_collection = FeatureCollection.new @query_results, nation_slug, claim.get_claimers
  end

  def get_all
    @feature_collection.to_a
  end
end
