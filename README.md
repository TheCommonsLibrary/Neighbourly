# Neighbourly

### Local setup

1. Run `gem install bundler -v 1.15.3`
2. Run `bundle install`
3. Create the database by running `psql` then executing the following command:
  ```
  CREATE DATABASE neighbourly ENCODING 'UTF_8';
  CREATE DATABASE neighbourly_test ENCODING 'UTF_8';
  ```
4. Exit `psql` and run the migrations for the app database:
  ```
  DATABASE_URL="postgres://localhost/neighbourly" rake db:migrate
  psql neighbourly < pcode_table.sql
  ```
5. Create a new `.env` file in the project root and set the environment variables according to the examples in .env.example.
6. Run `ruby app.rb` to start the application

### Deployment

1. Download and install the [Heroku toolbelt](https://devcenter.heroku.com/articles/heroku-cli#download-and-install). You can skip this step if you have previously installed this tool on your computer.
2. Open terminal and run the following commands:
  - `heroku create`
  - `git push heroku master`
  - `heroku run rake db:migrate`
  - `heroku pg:psql < pcode_table.sql`
3. Set environment variables in Heroku according to .env.example

### Notes

- Claims are not set to expire at this stage, though that feature could be added (a version existed in the earlier version of Neighbourly)
