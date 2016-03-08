require 'erb'
require 'sinatra'
require 'sqlite3'
require_relative 'customer'
require_relative 'SignUp'
#require_relative 'curry_house_twitter'

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

get '/instructions' do
  erb :instructions
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
  @page_header = 'Dashboard'
  erb :admin_panel
end
