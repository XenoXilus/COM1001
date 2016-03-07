require 'erb'
require 'sinatra'
require 'sqlite3'
require_relative 'customer'

include ERB::Util

get '/' do

  erb :index
end

get '/menu' do

  erb :menu
end

get '/about' do

  erb :about
end

get '/login' do
    erb :access
end

post '/user_signup' do
    @firstname = params[:inputName].strip
    @surname = params[:inputSurname].strip
    @twitterUname = params[:inputTwitter].strip
    @email = params[:inputEmail2].strip
    @password = params[:inputPassword].strip


    erb :index
end

get '/admin' do
    erb :admin_panel
end
