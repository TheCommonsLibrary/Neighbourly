class FeatureCollection

  def initialize(query_results, nation_slug, mesh_block_claimers)
  	@nation_slug = nation_slug
  	@mesh_blocks = query_results['hits']['hits']
    @mesh_block_claimers = mesh_block_claimers
  end

  def to_a
    @mesh_blocks.map do |mesh_block|
      claimed_by = @mesh_block_claimers[mesh_block['_source']['slug']] # what exactly is this? we need a better name
      {
        type: 'Feature',
        geometry: mesh_block['_source']['location'],
        properties: {
          slug: mesh_block['_source']['slug'],
          type: mesh_block['_source']['type'],
          claimedBy: define_claimed_by_status_from(claimed_by)
        }
      }
    end
  end

  private
  def define_claimed_by_status_from(claimed_by)
    return 'unclaimed' if claimed_by.nil?
    claimed_by == @nation_slug ? 'selected' : 'claimed'
  end
end
