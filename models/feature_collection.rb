require_relative './claim_status'

class FeatureCollection

  def initialize(query_results, nation_slug, mesh_block_claimers)
  	@nation_slug = nation_slug
  	@mesh_blocks = query_results['hits']['hits']
    @mesh_block_claimers = mesh_block_claimers
  end

  def to_a
    @mesh_blocks.map do |mesh_block|
      mesh_block_slug = mesh_block['_source']['slug']
      claimer = @mesh_block_claimers[mesh_block_slug]
      {
        type: 'Feature',
        geometry: mesh_block['_source']['location'],
        properties: {
          slug: mesh_block_slug,
          type: mesh_block['_source']['type'],
          claimedBy: claimer,
          state: define_claimed_by_status_from(claimer),
        }
      }
    end
  end

  private
  def define_claimed_by_status_from(claimer)
    return ClaimStatus::UNCLAIMED if claimer.nil?
    claimer == @nation_slug ? ClaimStatus::SELECTED : ClaimStatus::CLAIMED
  end
end
