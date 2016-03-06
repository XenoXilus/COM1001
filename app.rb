require 'sinatra'
require 'sqlite3'
require_relative 'customer'
#require_relative 'curry_house_twitter'

get '/' do
  erb :index
end

get '/menu' do
  erb :menu
end

get '/about' do
  erb :about
end

get '/instructions' do
  erb :instructions
end

get '/login' do
  erb :access
end

get '/admin' do
  erb :admin_panel
end
