require_relative "../../../services/claim_service"

describe "ClaimService" do

  let(:db) { RSpec.configuration.db }

  before :each do
    db[:users].insert(email: "user1@example.com")
    db[:users].insert(email: "user2@example.com")
    db[:claims].insert(mesh_block_slug: "slug1", mesh_block_claimer: "user1@example.com", claim_date: Time.now)
    db[:claims].insert(mesh_block_slug: "slug2", mesh_block_claimer: "user2@example.com", claim_date: Time.now)
    db[:claims].insert(mesh_block_slug: "slug3", mesh_block_claimer: "user1@example.com", claim_date: Time.now)
    @claim_service = ClaimService.new(db)
  end

  after :each do
    db[:claims].delete
    db[:users].delete
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

  describe "#get_claimers_for" do
    it "should get claimers for mesh_blocks" do
      expect(@claim_service.get_claimers_for(mesh_blocks)).to eq({"slug1"=>{email: "user1@example.com", name: nil, organisation: nil, phone: nil, created_at: nil}, "slug2"=>{email: "user2@example.com", name: nil, organisation: nil, phone: nil, created_at: nil}, "slug3"=>{email: "user1@example.com", name: nil, organisation: nil, phone: nil, created_at: nil}})
    end
  end

  describe "#get_mesh_blocks_for" do
    it "should get mesh_blocks for a claimer" do
      expect(@claim_service.get_mesh_blocks_for("user1@example.com")).to eq(["slug1", "slug3"])
    end
  end

  describe "#get_when_claimed_by_others" do
    let(:user) { "user1@example.com" }
    context "when not claimed by others" do
      let(:block_slugs) { [ "slug4", "slug4" ] }
      it { expect(@claim_service.get_when_claimed_by_others(block_slugs, user)).to be_empty }
    end

    context "when not claimed by others" do
      let(:block_slugs) { [ "slug1", "slug2", "slug3" ] }
      it { expect(@claim_service.get_when_claimed_by_others(block_slugs, user)).to contain_exactly(contain_exactly("slug2", "user2@example.com")) }
    end
  end

	describe '#claim' do
		it 'should save mesh block slug and claimer into database' do
			mesh_blocks = ["mesh_block_1", "mesh_block_2"]
			claimer = 'claimer'
      expect(@claim_service.claim(mesh_blocks, claimer)).to contain_exactly('mesh_block_1', 'mesh_block_2');

      expect(@claim_service.get_mesh_blocks_for(claimer)).to eq(["mesh_block_1", "mesh_block_2"])
      db[:claims].delete
    end
  end
end
