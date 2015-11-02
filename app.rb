require 'sinatra'
require 'erb'
require 'sequel'
require 'time'

configure do
  db = Sequel.connect('postgres://localhost/walklist')
  set :db, db
end

configure :production do
end

Sequel.datetime_class = DateTime

get '/' do
  erb :"main"
end
