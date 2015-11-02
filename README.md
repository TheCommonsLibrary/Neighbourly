# walklist
walklist tool in collab with TW


# Devbox setup

1. Install postgres
2. From psql run `CREATE DATABASE walklist ENCODING 'UTF_8';`
3. From psql run `CREATE DATABASE walklist_test ENCODING 'UTF_8';`
4. From bash run sequel migration `sequel -m migrations/ postgres://localhost/walklist`
