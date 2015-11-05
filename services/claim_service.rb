#TODO: class should become a proper sequel model
class ClaimService

  def initialize(db)
    @db = db
  end

  def get_claimers(mesh_blocks)
    @db[:claims].
      where(mesh_block_slug: get_mesh_block_slugs(mesh_blocks)).
      where("claim_date > now() - INTERVAL '2 weeks'").
      select(:mesh_block_claimer, :mesh_block_slug).
      map { |row| 
        [ row[:mesh_block_slug], row[:mesh_block_claimer] ]
      }.to_h
  end

  private
  def get_mesh_block_slugs(mesh_blocks)
    mesh_blocks.map { |mesh_block| mesh_block['_source']['slug'] }
  end
end
