Sequel.migration do
  up do
    create_table(:partners) do
      primary_key :id
      String :partner_name, :null=>false
      String :nation_slug, :null=>false
    end
  end

  down do
    drop_table(:partners)
  end
end
