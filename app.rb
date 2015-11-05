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
require 'sinatra/json'

require_relative 'lib/nation_helper'
require_relative 'lib/view_helper'
require_relative 'lib/params_helper'
require_relative './services/elastic_search/mesh_block_query'
require_relative './services/claim_service'
require_relative './models/feature_collection'

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

def test_db_connection
  Sequel.connect(ENV['SNAP_DB_PG_URL'] || "postgres://localhost/walklist_test")
end

configure do
  db = Sequel.connect('postgres://localhost/walklist')
  set :db, db
end

configure :production do
  db = Sequel.connect(ENV['DATABASE_URL'])
  set :db, db
end

configure :test do
  set :db, test_db_connection
end

Sequel.datetime_class = DateTime

get '/' do
  if authorised?
    redirect '/map'
  else
    haml :main, locals: {body: 'main'}
  end
end

get '/login' do
  redirect '/'
end

post '/login' do
  nation = nation_param
  nation_slug(nation) #sets the nation slug
  oauth_client = OAuth2::Client.new(ENV['OAUTH_CLIENT_ID'], ENV['OAUTH_CLIENT_SECRET'], :site => site_path)
  redirect oauth_client.auth_code.authorize_url(:redirect_uri => ENV['REDIRECT_URI'])
end

get '/authorise' do
  code = code_param
  oauth_client = OAuth2::Client.new(ENV['OAUTH_CLIENT_ID'], ENV['OAUTH_CLIENT_SECRET'], :site => site_path)
  auth = oauth_client.auth_code.get_token(code, :redirect_uri => ENV['REDIRECT_URI'])
  nation_token(auth.token) #sets the auth token for this session.
  redirect '/map'
end

get '/map' do
  authorised do
    haml :map, :layout => false
  end
end

get '/logout' do
  session.clear
  flash[:notice] = 'You have been logged out.'
  redirect '/'
end

get '/electorate/:id/meshblocks' do
  authorised do
    electorate_id = params[:id]
    
    claim_service = ClaimService.new(settings.db)
    elastic_search_connection = ElasticSearch::Connection.new
    mesh_block_query = ElasticSearch::Query::MeshBlocksQuery.new(electorate_id, elastic_search_connection)

    query_results = mesh_block_query.execute
    mesh_blocks = query_results['hits']['hits']
    mesh_blocks_claimers = claim_service.get_claimers_for(mesh_blocks)

    feature_collection = FeatureCollection.new(query_results, nation_slug, mesh_blocks_claimers)

    json feature_collection.to_a
  end
end

get '/download' do
  authorised do
    claim_service = ClaimService.new(settings.db)
    claimed_mesh_blocks = claim_service.get_mesh_blocks_for(nation_slug)
    haml :download, locals: { selected_slugs: params[:slugs] || [], claimed_slugs: claimed_mesh_blocks }
  end
end

post '/claim' do
  authorised do
    claim_service = ClaimService.new(settings.db)
    claim_service.claim(params[:slugs], nation_slug)
  end
end

