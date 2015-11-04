Sequel.migration do
  up do
   alter_table(:mesh_block_claims) do
    rename_column :nation, :mesh_block_claimer
    rename_column :mesh_block_id, :mesh_block_slug
    add_index :mesh_block_slug
   end
   drop_table(:partners)
  end

  down do
    create_table(:partners) do
      primary_key :id
      String :partner_name, :null=>false
      String :nation_slug, :null=>false
    end
  end
end
