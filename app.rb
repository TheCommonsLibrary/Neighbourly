require 'sinatra'
require 'erb'
require 'oauth2'
require 'byebug'
require 'dotenv'
require 'haml'
require 'sequel'
require 'time'
require "sinatra/reloader" if development?
require "httparty"
require 'json'
require 'sinatra/flash'

require_relative 'lib/nation_helper'
require_relative 'lib/view_helper'
require_relative 'services/electorate_service'

Dotenv.load
enable :sessions

ELECTORATES = 
  {"Batman"   => "301020",
  "Bonner"   => "300989",
  "Brisbane" => "300991",
  "Curtin"   => "300923",
  "Deakin"   => "301028",
  "Denison"  => "300937",
  "Dunkley"  => "301029",
  "Higgins"  => "301035",
  "Hindmarsh"=> "301059",
  "Kooyong"  => "301041",
  "McEwen"   => "301046",
  "Melbourne"=> "301048",
  "Moreton"  => "301011",
  "Petrie"   => "301013",
  "Reid"     => "300977",
  "Ryan"     => "301015",
  "Sturt"    => "301064",
  "Wentworth"=> "300986"}

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
  if authorised?
    redirect '/electorates'
  else
    haml :main, locals: {body: 'main'}
  end
end

get '/login' do
  redirect '/'
end

post '/login' do
  nation_slug(params['nation']) #sets the nation slug
  oauth_client = OAuth2::Client.new(ENV['OAUTH_CLIENT_ID'], ENV['OAUTH_CLIENT_SECRET'], :site => site_path)
  redirect oauth_client.auth_code.authorize_url(:redirect_uri => ENV['REDIRECT_URI'])
end

get '/authorise' do
  code = params['code']
  oauth_client = OAuth2::Client.new(ENV['OAUTH_CLIENT_ID'], ENV['OAUTH_CLIENT_SECRET'], :site => site_path)
  auth = oauth_client.auth_code.get_token(code, :redirect_uri => ENV['REDIRECT_URI'])
  nation_token(auth.token) #sets the auth token for this session.
  redirect '/electorates'
end

get '/electorates' do
  authorised do
    haml :electorates
  end
end

get '/map' do
  authorised do
    haml :map
  end
end

#not needed for now
get '/electorate/:id/meshblocks' do
  authorised do
    electorate_id = params[:id]
    electorate_service = ElectorateService.new(electorate_id)
    electorate_service.get_mesh_blocks
  end
end

post '/download' do
  authorised do
    haml :download, locals: { slugs: param['slugs'] }
  end
end
