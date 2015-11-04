require_relative './mesh_block_query'
require_relative './../models/mesh_blocks_claim'
require_relative './feature_collection'

class MeshBlockService
  def initialize(electorate_id, db, nation_slug)
    @db = db
    @query_results = MeshBlocksQuery.new(electorate_id).execute
    @feature_collection = FeatureCollection.new @query_results, nation_slug
  end

  def get_all
    claim = MeshBlockClaim.new(@db, @query_results['hits']['hits'])
    @feature_collection.format_meshblocks claim.get_claimers
  end
end
