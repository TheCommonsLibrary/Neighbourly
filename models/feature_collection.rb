require_relative './claim_status'

class FeatureCollection

  def initialize(query_results, user_email, mesh_block_claimers)
  	@user_email = user_email
  	@mesh_blocks = query_results['hits']['hits']
    @mesh_block_claimers = mesh_block_claimers
  end

  def to_a
    @mesh_blocks.map do |mesh_block|
      mesh_block_slug = mesh_block['_source']['slug']
      claimer_details = @mesh_block_claimers[mesh_block_slug]
      {
        type: 'Feature',
        geometry: mesh_block['_source']['location'],
        properties: {
          slug: mesh_block_slug,
          type: mesh_block['_source']['type'],
          claimedBy: claimer_details,
          state: define_claimed_by_status_from(claimer_details),
        }
      }
    end
  end

  private

  def define_claimed_by_status_from(claimer_details)
    return ClaimStatus::UNCLAIMED if claimer_details.nil?
    claimer_details[:email] == @user_email ? ClaimStatus::SELECTED : ClaimStatus::CLAIMED
  end
end
