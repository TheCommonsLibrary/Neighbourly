require_relative '../../../services/claim_service'

describe 'ClaimService' do

	let(:db) { RSpec.configuration.db }
		
	before :each do
		db[:claims].insert(:mesh_block_slug => 'slug1', :mesh_block_claimer => 'user1', :claim_date => Time.now)
		db[:claims].insert(:mesh_block_slug => 'slug2', :mesh_block_claimer => 'user2', :claim_date => Time.now)
		db[:claims].insert(:mesh_block_slug => 'slug3', :mesh_block_claimer => 'user1', :claim_date => Time.now)
		@claim_service = ClaimService.new(db)
	end

	let(:mesh_blocks) {
		[
	     {
	       "_source" => {
	         "slug" => "slug1",
	         "type" => "MeshBlock",
	       }
	      },
	      {
	       "_source" => {
	         "slug" => "slug2",
	         "type" => "MeshBlock",
	       }
	      },
	      {
	       "_source" => {
	         "slug" => "slug3",
	         "type" => "MeshBlock",
	       }
	      }
    	]
	}

	describe '#get_claimers_for' do
		it 'should get claimers for mesh_blocks' do
			expect(@claim_service.get_claimers_for(mesh_blocks)).to eq({"slug1"=>"user1", "slug2"=>"user2", "slug3"=>"user1"})
			db[:claims].delete
		end
	end

	describe '#get_mesh_blocks_for' do
		it 'should get mesh_blocks for a claimer' do
			expect(@claim_service.get_mesh_blocks_for("user1")).to eq(["slug1", "slug3"])
			db[:claims].delete
		end
	end

	describe '#claim' do
		it 'should save mesh block slug and claimer into database' do
			mesh_blocks = ["mesh_block_1", "mesh_block_2"]
			claimer = 'claimer'
			@claim_service.claim(mesh_blocks, claimer)

			expect(@claim_service.get_mesh_blocks_for(claimer)).to eq(["mesh_block_1", "mesh_block_2"])
			db[:claims].delete
		end
	end
end


















