#TODO: class should become a proper sequel model
class MeshBlockClaim

  def initialize(db, mesh_blocks)
    @db = db
    @mesh_blocks = mesh_blocks
  end

  def get_claimers
    dataset[:mesh_block_claims].
      where(mesh_block_slug: get_mesh_block_slugs()).
      where("claim_date > now() - INTERVAL '2 weeks'").
      select(:mesh_block_claimer, :mesh_block_slug).
      map { |row| 
        [ row[:mesh_block_slug], row[:mesh_block_claimer] ]
      }.to_h
  end

  private
  def get_mesh_block_slugs
    @mesh_blocks.map { |mesh_block| mesh_block['_source']['slug'] }
  end
end
