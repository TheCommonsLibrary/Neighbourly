require 'sinatra'
require 'erb'

get '/' do
  erb :"main"
end