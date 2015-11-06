require_relative "../../models/feature_collection"

describe "FeatureCollection" do

  describe "#to_a" do

    let(:db) { RSpec.configuration.db }

    before :each do
      db[:users].insert(email: "user1@example.com")
      db[:users].insert(email: "user2@example.com")
      db[:claims].insert(mesh_block_slug: "slug1", mesh_block_claimer: "user1@example.com", claim_date: Time.now)
      db[:claims].insert(mesh_block_slug: "slug2", mesh_block_claimer: "user2@example.com", claim_date: Time.now)
    end

    after :each do
      db[:claims].delete
      db[:users].delete
    end

    let(:query_result) {
      {
       "hits" => {
         "total" => 460,
         "max_score" => 1.0030303,
         "hits" => [
           {
             "_index" => "territories",
             "_type" => "territory",
             "_id" => "299974",
             "_score" => 1.0030303,
             "_source" => {
               "slug" => "slug1",
               "type" => "MeshBlock",
               "location" => {
                 "type" => "MultiPolygon",
                 "coordinates" => [
                   [
                     [
                       [
                         150.286818304,
                         -28.5381470905
                       ]
                     ]
                   ]]
                }
              }
            },
            {
             "_index" => "territories",
             "_type" => "territory",
             "_id" => "299974",
             "_score" => 1.0030303,
             "_source" => {
               "slug" => "slug2",
               "type" => "MeshBlock",
               "location" => {
                 "type" => "MultiPolygon",
                 "coordinates" => [
                   [
                     [
                       [
                         150.286818304,
                         -28.5381470905
                       ]
                     ]
                   ]]
                }
              }
            },
            {
             "_index" => "territories",
             "_type" => "territory",
             "_id" => "299974",
             "_score" => 1.0030303,
             "_source" => {
               "slug" => "slug3",
               "type" => "MeshBlock",
               "location" => {
                 "type" => "MultiPolygon",
                 "coordinates" => [
                   [
                     [
                       [
                         150.286818304,
                         -28.5381470905
                       ]
                     ]
                   ]]
                }
              }
            },
          ]
        }
      }
    }

    let(:mesh_block_claimers) {
      {
        "slug1"=>{email: "user1@example.com"},
        "slug2"=>{email: "user2@example.com"},
      }
    }

    it "should convert raw query data into correct mash block format" do
      feature_collection = FeatureCollection.new query_result, "user1@example.com", mesh_block_claimers

      mesh_blocks = feature_collection.to_a

      expect(mesh_blocks[0]).to eq({type: "Feature",
                                    geometry: {
                                      "type"=>"MultiPolygon",
                                      "coordinates"=>[[[[150.286818304, -28.5381470905]]]]},
                                    properties: {
                                      slug: "slug1",
                                      type: "MeshBlock",
                                      claimedBy: {email: "user1@example.com"},
                                      state: "selected"}
                                    })

      expect(mesh_blocks[1][:properties][:state]).to eq("claimed")
      expect(mesh_blocks[2][:properties][:state]).to eq("unclaimed")
    end

  end
end
