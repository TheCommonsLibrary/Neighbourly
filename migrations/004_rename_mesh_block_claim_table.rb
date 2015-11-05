Sequel.migration do
  up do
   rename_table :mesh_block_claims, :claims
  end

  down do
   rename_table :claims, :mesh_block_claims
  end
end
