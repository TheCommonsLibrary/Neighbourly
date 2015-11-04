require_relative './mesh_block_query'
require_relative './elastic_search_gateway'

class ElectorateService

  def initialize(electorate_id)
    @mesh_block_query = MeshBlocksQuery.new electorate_id
  end

  def get_mesh_blocks(db, nation_slug)
    parsed_response = @mesh_block_query.execute
    elastic_search_gateway = ElasticSearchGateway.new(parsed_response, nation_slug)

    if parsed_response.include?("error")
      {}
    else
      mesh_blocks = parsed_response['hits']['hits']
      mesh_block_claimers = get_claimers(mesh_blocks, db)
      elastic_search_gateway.format_meshblocks(mesh_block_claimers)
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
end
