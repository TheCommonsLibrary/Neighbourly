require 'sinatra'
require "sinatra/reloader" if development?
require 'byebug' if development?
require 'dotenv'
require 'haml'
require 'sequel'
require 'time'
require "httparty"
require 'json'
require 'sinatra/flash'
require 'sinatra/json'

require_relative "lib/login_helper"
require_relative 'lib/view_helper'
require_relative './services/elastic_search/mesh_block_query'
require_relative './services/claim_service'
require_relative './models/feature_collection'
require_relative "models/user"
require_relative "models/electorate"

Dotenv.load
enable :sessions
set :session_secret, ENV["SECRET_KEY_BASE"]

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
  email = params[:email].strip
  user = User.new(settings.db)
  if user.where(email: email).any?
    authorise(email)
    redirect "/map"
  else
    redirect "/user_details?email=#{CGI.escape(email)}"
  end
end

get "/user_details" do
  haml :user_details, locals: { email: params[:email] }
end

post "/user_details" do
  user = User.new(settings.db)
  if user.create!(params[:user_details])
    authorise(params[:user_details]['email'])
    redirect "/map"
  else
    # TODO needs validation
    flash[:error] = "Please enter correct details."
    haml :user_details
  end
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

    feature_collection = FeatureCollection.new(query_results, user_email, mesh_blocks_claimers)

    json feature_collection.to_a
  end
end

post '/download' do
  authorised do
    all_selected_slugs = (params[:slugs] || [])
    claim_service = ClaimService.new(settings.db)
    user = User.new(settings.db)
    claimed_mesh_blocks = claim_service.get_mesh_blocks_for(user_email)
    unclaimable_mesh_blocks = claim_service.get_when_claimed_by_others(all_selected_slugs, user_email).
                                map { |slug, email| [ slug, user.where(email: email).first ] }.to_h
    claimable_mesh_blocks = all_selected_slugs.
                              select { |slug| !unclaimable_mesh_blocks.include?(slug) }.
                              select { |slug| !claimed_mesh_blocks.include?(slug) }
    haml :download, locals: { claimable_slugs: claimable_mesh_blocks, unclaimable_slugs: unclaimable_mesh_blocks, claimed_slugs: claimed_mesh_blocks }
  end
end

post '/claim' do
  authorised do
    claim_service = ClaimService.new(settings.db)
    claimed = claim_service.claim((params[:slugs] || []), user_email)
    content_type :json
    {claimed: claimed}.to_json
  end
end
