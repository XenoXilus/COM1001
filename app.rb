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

include ERB::Util

enable :sessions

get '/' do

  db = SQLite3::Database.new './curry_house.sqlite'
  @caught_tweets = db.execute('SELECT * FROM tweets')
  erb :index
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


get '/admin' do
  if !session[:admin]
    redirect '/'
  end
  @page_header = 'Dashboard'

  erb :admin_panel
end

not_found do

  erb :error404
end

# error do
#
#   erb :gen_error
# end
