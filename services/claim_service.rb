#TODO: class should become a proper sequel model
class ClaimService

  def initialize(db)
    @db = db
  end

  def get_claimers_for(mesh_blocks)
    @db[:claims]
      .where(mesh_block_slug: get_mesh_block_slugs(mesh_blocks))
      .where("claim_date > now() - INTERVAL '2 weeks'")
      .select(:mesh_block_claimer, :mesh_block_slug)
      .map { |row|
        [ row[:mesh_block_slug], claimer_details(row[:mesh_block_claimer]) ]
      }.to_h
  end

  def get_mesh_blocks_for(claimer)
    @db[:claims].
      where(mesh_block_claimer: claimer).
      where("claim_date > now() - INTERVAL '2 weeks'").
      select(:mesh_block_slug).
      map { |row|
        row[:mesh_block_slug]
      }
  end

  def get_when_claimed_by_others(mesh_blocks, user_email)
    @db[:claims].
      where(mesh_block_slug: mesh_blocks).
      exclude(mesh_block_claimer: user_email).
      where("claim_date > now() - INTERVAL '2 weeks'").
      select(:mesh_block_claimer, :mesh_block_slug).
      map { |row|
        [ row[:mesh_block_slug], row[:mesh_block_claimer] ]
      }.to_h
  end

  def claim(mesh_blocks, claimer)
    claimed = []
    mesh_blocks.each do |mesh_block|
      begin
        @db[:claims].insert(mesh_block_slug: mesh_block, mesh_block_claimer: claimer, claim_date: Time.now)
        claimed = claimed + [ mesh_block ] 
      rescue
      end
    end
    claimed
  end

  private
  def claimer_details(email)
    @db[:users].where(email: email).first
  end

  def get_mesh_block_slugs(mesh_blocks)
    mesh_blocks.map { |mesh_block| mesh_block['_source']['slug'] }
  end
end
