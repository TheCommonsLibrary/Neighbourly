Sequel.migration do
  up do
    create_table(:users) do
      String :email, primary_key: true
      String :name
      String :organisation
      String :phone
      DateTime :created_at
    end
  end

  down do
    drop_table(:users)
  end
end
