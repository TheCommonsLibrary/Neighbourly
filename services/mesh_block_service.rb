require_relative './elastic_search/mesh_block_query'
require_relative './claim_service'
require_relative './../models/feature_collection'

class MeshBlockService 
  def initialize(electorate_id, db, nation_slug)
    @query_results = ElasticSearch::Query::MeshBlocksQuery.new(electorate_id).execute
    claim = ClaimService.new(db)
    @feature_collection = FeatureCollection.new @query_results, nation_slug, claim.get_claimers(@query_results['hits']['hits'])
  end

  def get_all
    @feature_collection.to_a
  end
end
