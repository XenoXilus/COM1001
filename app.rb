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
    if !session[:logged_in]
        Stats.increment 'total_visits' #todo to-be-changed
    end

    if !session[:city].nil?
        @city = session[:city]
    end

    erb :index
end

get '/setSheff' do
    session[:city] = "sheffield"
    redirect '/'
end

get '/setBirm' do
    session[:city] = "birmingham"
    redirect '/'
end

get '/about' do
    erb :about
end

get '/instructions' do
    erb :instructions
end

post '/user_signup' do
    @firstname = params[:inputName].strip
    @surname = params[:inputSurname].strip
    @twitterUname = params[:inputTwitter].strip
    @email = params[:inputEmail2].strip
    @password = params[:inputPassword].strip

    erb :index
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
