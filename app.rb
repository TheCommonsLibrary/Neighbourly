require 'sinatra'
require 'haml'
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
  haml :main
end

get '/oauth_callback?code' do
	response = HTTParty.post('https://foobar.nationbuilder.com/oauth/tokenclient_id=...
			  				redirect_uri=' + 'http://localhost:4567/home' +
							'grant_type=authorization_code' + 
							'client_secret=' + ENV['CLIENT_SECRET'] +
							'code=' + params[:code])

	puts response['access_token']
end
