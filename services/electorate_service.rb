require_relative './mesh_block_query'

class ElectorateService

  def initialize(electorate_id)
    @mesh_block_query = MeshBlocksQuery.new electorate_id
  end

  def get_mesh_blocks(db, nation_slug)
    parsed_response = @mesh_block_query.execute
    if parsed_response.include?("error")
      {}
    else
      mesh_blocks = parsed_response['hits']['hits']
      mesh_block_claimers = get_claimers(mesh_blocks, db)
      format_meshblocks(mesh_blocks, mesh_block_claimers, nation_slug)
    end
  end

  private
  def get_mesh_block_slugs(mesh_blocks)
    mesh_blocks.map { |mesh_block| mesh_block['_source']['slug'] }
  end

  def get_claimers(mesh_blocks, db)
    db[:mesh_block_claims].
      where(mesh_block_slug: get_mesh_block_slugs(mesh_blocks)).
      where("claim_date > now() - INTERVAL '2 weeks'").
      select(:mesh_block_claimer, :mesh_block_slug).
      map { |row| 
        [ row[:mesh_block_slug], row[:mesh_block_claimer] ]
      }.to_h
  end

  def format_meshblocks(mesh_blocks, mesh_block_claimers, nation_slug)
    mesh_blocks.map do |mesh_block|
      claimed_by = mesh_block_claimers[mesh_block['_source']['slug']]
      {
        type: 'Feature',
        geometry: mesh_block['_source']['location'],
        properties: {
          slug: mesh_block['_source']['slug'],
          type: mesh_block['_source']['type'],
          claimedBy: get_claimed_by_flag(claimed_by, nation_slug)
        }
      }
    end
  end

  def get_claimed_by_flag(claimed_by, nation_slug)
    # using three flags to denoted claim status of the a mesh block 
    # unclaimed which means not claimed at all
    # selected which means claimed by currently logged in nation
    # claimed which means this mesh block is claimed by another nation
    if claimed_by == nil
      'unclaimed'
    else
      claimed_by == nation_slug ? 'selected' : 'claimed'
    end
  end
end
