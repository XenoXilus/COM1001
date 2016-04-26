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

get '/login' do
  if session[:logged_in]
    redirect '/'
  end

  erb :login
end



post '/login' do

  @submitted = true

  email_address=params[:email_address].strip
  pswrd=params[:password].strip

  @password_ok=true

  name=@db.execute('SELECT firstName FROM customer WHERE email = ? ',[email_address])
  # puts 1
  # puts name[0]
  # puts 2

  @email_address_ok=!name[0].nil?

  if @email_address_ok
    surname = @db.execute('SELECT surname FROM customer WHERE email = ? AND password=?',[email_address,pswrd])
    @password_ok = !surname[0].nil?
  end
  # puts @email_address_ok
  # puts @password_ok



  @everything_ok = @password_ok && @email_address_ok


  if @everything_ok
    session[:logged_in] = true
    Stats.increment 'logins'
    session[:login_time] = Time.now
    session[:email] = email_address
    session[:twitter_acc] = @db.get_first_value('SELECT twitterAcc FROM customer WHERE email = ?',email_address)

    admin_ok=email_address=='admin@ch.com'

    if admin_ok then
      session[:admin] = true
    else
      session[:admin] = false
    end
    redirect '/'
  end

  @error = 'The Email address or the password is not correct'

  erb :login
end

get '/logout' do
  if !session[:logged_in]
    redirect '/'
  end
  session.clear
  erb :logout
end

