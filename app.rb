require 'sinatra'
require 'erb'
require 'sequel'

configure do
  db = Sequel.connect('postgres://localhost/walklist')
  set :db, db
end

configure :production do
end

get '/' do
  erb :"main"
end
