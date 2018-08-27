Sequel.migration do
  up do
    create_table(:users) do
      String :email, primary_key: true
      String :first_name
      String :last_name
      String :phone
      String :postcode
      DateTime :created_at
      index :email
    end
  end

  down do
    drop_table(:users)
  end
end
