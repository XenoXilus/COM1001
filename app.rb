require 'erb'
require 'sinatra'
require 'sqlite3'
require 'twitter'

require_relative 'account'
require_relative 'SignUp'
require_relative 'LogIn'
require_relative 'menu'
require_relative 'curry_house_twitter'
require_relative 'orders'
require_relative 'admin'
require_relative 'offers'
require_relative 'statistics'

include ERB::Util

enable :sessions

#todo force user to select a city
# get '/' do
#   if !(session[:sheffield] || session[:birmingham])
#
#   else
#     redirect '/index'
#   end
# end

get '/' do
    if !session[:city].nil?
        @city = session[:city]
        @city=@city.capitalize!
    end

    erb :index
end

get '/setSheff' do
    session[:city] = "sheffield"
    Stats.increment 'total_visits','sheffield'
    redirect '/'
end

get '/setBirm' do
    session[:city] = "birmingham"
    Stats.increment 'total_visits','birmingham'
    redirect '/'
end

get '/about' do
    erb :about
end

get '/instructions' do
    erb :instructions
end


get '/sheffMenu' do
	erb :sheffMenuEdit
end
get '/birmMenu' do
	erb :birmMenuEdit
end

not_found do
    erb :error404
end

def active_page?(path='')
    request.path_info == '/' + path
end