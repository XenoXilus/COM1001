require 'sinatra'

get '/' do

  erb :index
end

get '/menu' do

  erb :menu
end

get '/about' do

  erb :about
end