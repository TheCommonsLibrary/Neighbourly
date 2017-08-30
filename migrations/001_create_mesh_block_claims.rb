require 'time'

Sequel.migration do
  up do
    create_table(:mesh_block_claims) do
      primary_key :id
      String :mesh_block_id, :null=>false
      String :nation, :null=>false
      DateTime :claim_date, :null=>false
      index :mesh_block_id
    end
  end

  down do
    drop_table(:mesh_block_claims)
  end
end
