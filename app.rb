require 'sinatra'
require 'erb'
require 'oauth2'
require 'byebug'
require 'dotenv'
require 'haml'
require 'sequel'
require 'time'
require "sinatra/reloader" if development?

Dotenv.load
enable :sessions

configure do
  db = Sequel.connect('postgres://localhost/walklist')
  set :db, db
end

configure :production do
end

configure :test do
  db = Sequel.connect(ENV['SNAP_DB_PG_URL'] || "postgres://localhost/walklist_test")
  set :db, db
end

Sequel.datetime_class = DateTime

get '/' do
  haml :main
end

post '/login' do
  nation = params['nation']
  puts "nation = #{nation}"
  site_path = "https://#{nation}.nationbuilder.com"
  session[:site_path] = site_path
  oauth_client = OAuth2::Client.new(ENV['OAUTH_CLIENT_ID'], ENV['OAUTH_CLIENT_SECRET'], :site => site_path)
  redirect oauth_client.auth_code.authorize_url(:redirect_uri => ENV['REDIRECT_URI'])
end

get '/home' do
  code = params['code']
  oauth_client = OAuth2::Client.new(ENV['OAUTH_CLIENT_ID'], ENV['OAUTH_CLIENT_SECRET'], :site => session[:site_path])
  token = oauth_client.auth_code.get_token(code, :redirect_uri => ENV['REDIRECT_URI'])
  puts token
  #TODO store token?
  haml :"home"
end
