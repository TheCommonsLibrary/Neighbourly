class ElasticSearchGateway

  def initialize(query_results, nation_slug)
  	@nation_slug = nation_slug
  	@mesh_blocks = query_results['hits']['hits']
  end

  def format_meshblocks(mesh_block_claimers)
    @mesh_blocks.map do |mesh_block|
      claimed_by = mesh_block_claimers[mesh_block['_source']['slug']]
      {
        type: 'Feature',
        geometry: mesh_block['_source']['location'],
        properties: {
          slug: mesh_block['_source']['slug'],
          type: mesh_block['_source']['type'],
          claimedBy: get_claimed_by_flag(claimed_by)
        }
      }
    end
  end

  private
  def get_claimed_by_flag(claimed_by)
    # using three flags to denoted claim status of the a mesh block 
    # unclaimed which means not claimed at all
    # selected which means claimed by currently logged in nation
    # claimed which means this mesh block is claimed by another nation
    if claimed_by == nil
      'unclaimed'
    else
      claimed_by == @nation_slug ? 'selected' : 'claimed'
    end
  end
end
