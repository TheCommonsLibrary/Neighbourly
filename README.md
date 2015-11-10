# walklist
walklist tool in collab with TW

# Devbox setup

1. Install postgres
2. From psql run `CREATE DATABASE walklist ENCODING 'UTF_8';`
3. From psql run `CREATE DATABASE walklist_test ENCODING 'UTF_8';`
4. From bash run db migration `DATABASE_URL="postgres://localhost/walklist" rake db:migrate`

# TEST
Run unit test: rake spec:unit_tests
Run acceptance test:
  1. Start your test server: bundle exec puma -e test -p 8080
  2. Run test: rake spec:acceptance
