require_relative './elastic_search/mesh_block_query'
require_relative './claim_service'
require_relative './../models/feature_collection'

class MeshBlockService 
  def initialize(claim_service, nation_slug, mesh_block_query)
    query_results = mesh_block_query.execute
    mesh_blocks = query_results['hits']['hits']
    @feature_collection = FeatureCollection.new(query_results, nation_slug, claim_service.get_claimers_for(mesh_blocks))
  end

  def get_all
    @feature_collection.to_a
  end
end
