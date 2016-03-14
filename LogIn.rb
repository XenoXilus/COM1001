require 'sinatra'
require 'erb'
require 'sqlite3'
require 'tilt/erb'

include ERB::Util

before do
  @db = SQLite3::Database.new('./curry_house.sqlite')
end

enable :sessions
set :session_secret, 'super secret'



get '/' do
  redirect '/login' unless session[:logged_in]
  @submitted = false

  erb :index
end

get '/login' do
  erb :login
end



post '/login' do

  @submitted = true

  ####check

  email_address=params[:email_address].strip

  pswrd=params[:password].strip

  name=@db.execute('SELECT Firstname FROM Info WHERE Email_address = ? ',[email_address])
  @email_address_ok=!name[0][0].nil?
  surname = @db.execute('SELECT surname FROM Info WHERE Email_address = ? AND Password=?',[email_address,pswrd])

  @password__ok = !surname[0].nil?
  puts @email_address_ok
  puts @password__ok
  puts pswrd


  @everything_ok = @password__ok && @email_address_ok

  if @everything_ok
    session[:logged_in] = true
    session[:login_time] = Time.now
    redirect '/'
  end
  @error = "The Email address or the password is not correct"

  erb :login
end

get '/logout' do
  session.clear

  erb :logout
end

