require_relative '../../../services/claim_service'

describe 'ClaimService' do

	describe '#get_claimers_for' do
		let(:db) { RSpec.configuration.db }
		
		before :each do
			db[:claims].insert(:mesh_block_slug => 'slug1', :mesh_block_claimer => 'user1', :claim_date => Time.now)
			db[:claims].insert(:mesh_block_slug => 'slug2', :mesh_block_claimer => 'user2', :claim_date => Time.now)
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
	      },
	    ]
		}
		
		it 'should get claimers for mesh_blocks' do
      claim_service = ClaimService.new(db)
      expect(claim_service.get_claimers_for(mesh_blocks)).to eq({"slug1"=>"user1", "slug2"=>"user2"})
			db[:claims].delete
		end

	end
end