bundle exec rake db:migrate
curl https://cli-assets.heroku.com/install.sh | sh
heroku pg:psql < pcode_table.sql
