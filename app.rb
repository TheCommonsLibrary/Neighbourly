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
require 'sinatra/cookies'

require_relative "lib/login_helper"
require_relative 'lib/view_helper'
require_relative './services/claim_service'
require_relative './services/geo_service'
require_relative './services/AwsLambda/connection'
require_relative "models/user"

Dotenv.load
enable :sessions
set :session_secret, ENV["SECRET_KEY_BASE"]

def test_db_connection
  Sequel.connect(ENV['SNAP_DB_PG_URL'] || "postgres://localhost/neighbourly_test")
end

configure do
  db = Sequel.connect('postgres://localhost/neighbourly')
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
    haml :main, locals: {page: 'main', body: 'main'}
  end
end

def login_attempt
  #Primary login method is e-mail
  #If a param is passed (form or URL) - use that
  #If a cookie is set - use that secondarily
  #If no e-mail is present, send to the frontpage
  if params.has_key?("email")
    authorise(params[:email].strip)
  elsif cookies.has_key?("email")
    authorise(cookies[:email])
  else
    redirect '/'
  end

  user_params = Hash.new
  fields = ["email", "first_name", "last_name", "phone", "postcode"]

  #Check that user exists for current e-mail
  if authorised?
    redirect "/map"

  #If e-mail is set in param - go straight to the user_details page
  elsif params.has_key?("email")
    redirect "/user_details?email=#{CGI.escape(user_email)}"

  #If user does not exist and all fields exist in cookie - create_user
  elsif fields.all? {|s| cookies.key? s}
    fields.each do |key_get|
      user_params[key_get] = cookies[key_get]
    end
  create_user(user_params)
  redirect "/map"

  end
end

get '/login' do
  login_attempt
end

post '/login' do
  login_attempt
end

get "/user_details" do
  haml :user_details, locals: {page: "user_details", email: params[:email] }
end

def create_user(user_params)
  puts "Creating user: #{user_params}"
  user = User.new(settings.db)
  #Submit user details to database
  #And, Catch double-submission errors and send details to Zapier
  begin
    if user.create!(user_params)

      #Send user details to the Zapier endpoint
      if ENV["ZAP_API_ON"] == "True"
        HTTParty.post(ENV["ZAP_API"],:body => user_params, timeout: 2)
      end

      #Once the user is created - authorise them
      authorise(user_params['email'])
      redirect "/map"
    else
      #TODO - needs validation
      flash[:error] = "Please enter correct details."
      haml :user_details
    end

  #Skip all errors and retry auth without ZAP_API call
  #REDUNDANT - Skip details re-entry if e-mail already exists in database
  #REDUNDANT - Skip if HTTParty fails to make the API call
rescue StandardError, Sequel::UniqueConstraintViolation, HTTParty::Error => e
    puts "Error in User Details Submission: #{e.message}"
    authorise(user_params['email'])
    redirect "/map"
  end
end

post "/user_details" do
  create_user(params[:user_details])
end

get '/map' do
  authorised do
    haml :map, locals: {page: 'map'}
  end
end

get '/logout' do
  session.clear
  flash[:notice] = 'You have been logged out.'
  redirect '/'
end

def get_meshblocks_with_status(json)
  slugs = Array.new
  json["features"].each do |slug|
    slugs << slug["properties"]["slug"]
  end
  claim_service = ClaimService.new(settings.db)
  claimed = Array.new
  centrally_claimed = Array.new
  claimed_by_you = Array.new
  claim_service.get_mesh_blocks(slugs).each do |claim|
    if is_admin?(claim[:mesh_block_claimer])
      centrally_claimed << claim[:mesh_block_slug]
    elsif claim[:mesh_block_claimer] == session[:user_email]
      claimed_by_you << claim[:mesh_block_slug]
    else
      claimed << claim[:mesh_block_slug]
    end
  end
  json["features"].each_with_index { |slug, index|
    if centrally_claimed.include? slug["properties"]["slug"]
      json["features"][index]["properties"]["claim_status"] = "quarantine"
    elsif claimed.include? slug["properties"]["slug"]
      json["features"][index]["properties"]["claim_status"] = "claimed"
    elsif claimed_by_you.include? slug["properties"]["slug"]
      json["features"][index]["properties"]["claim_status"] = "claimed_by_you"
    else
      json["features"][index]["properties"]["claim_status"] = "unclaimed"
    end
  }
  json
end

#For loading new SA1s when scrolling on the map
get '/meshblocks_bounds' do
  authorised do
    query = {'swlat' => params[:swlat],
    'swlng' => params[:swlng],
    'nelat' => params[:nelat],
    'nelng' => params[:nelng]}

    #interface with darren's tool goes here
    lambda_connection = AwsLambda::Connection.new

    #interface with local claims table goes here
    data = lambda_connection.execute(query)
    if data['features'] == nil
        puts "404 due to map location returning no meshblocks"
        status 404
    else
      json get_meshblocks_with_status(data)
    end
  end
end

#For finding out the bounds of a postcode
get '/pcode_get_bounds' do
  authorised do
    geo_service = GeoService.new(settings.db)
    bounds = geo_service.pcode_bounds(params[:pcode])
    json bounds[0]
  end
end

post '/claim_meshblock/:id' do
  authorised do
    claim_service = ClaimService.new(settings.db)
    claim_service.claim(params['id'], user_email)
    status 200
  end
end

post '/unclaim_meshblock/:id' do
  authorised do
    claim_service = ClaimService.new(settings.db)
    #TODO - return error on fail
    if is_admin?(user_email)
      claim_service.admin_unclaim(params['id'])
    else
      claim_service.unclaim(params['id'], user_email)
    end
    status 200
  end
end
