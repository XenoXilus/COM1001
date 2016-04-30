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
  else
    erb :login
  end
end



post '/login' do

  @submitted = true

  email_address = params[:email_address].strip
  pswrd = params[:password].strip

  name = @db.execute('SELECT firstName FROM customer WHERE email = ? ', email_address)
  @email_address_ok = !name[0].nil?

  if @email_address_ok
    surname = @db.execute('SELECT surname FROM customer WHERE email = ? AND password = ?', email_address, pswrd)
    @password_ok = !surname[0].nil?
    @blacklisted = @db.get_first_value('SELECT blacklisted FROM customer WHERE email = ?',email_address) == 1
  end


  @everything_ok = @password_ok && @email_address_ok && !@blacklisted


  if @everything_ok
    session[:logged_in] = true
    session[:city]= @db.get_first_value('SELECT city FROM customer WHERE email = ?',email_address)
    Stats.increment 'logins',session[:city]
    session[:login_time] = Time.now
    session[:email] = email_address
    session[:twitter_acc]  = @db.get_first_value('SELECT twitterAcc FROM customer WHERE email = ?',email_address)

    admin_ok =  !(@db.get_first_value('SELECT email FROM administrators WHERE email = ?',email_address)).nil?


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