require 'erb'
require 'sinatra'
require 'sqlite3'
require 'twitter'

include ERB::Util

before do
  @db = SQLite3::Database.new('curry_house.sqlite')
end

VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

get '/sign_up' do
  if session[:logged_in]
    redirect '/'
  end
  @submitted = false
  erb :access
end


post '/form_handler' do
  @submitted = true

  @firstname = params[:firstname].strip
  @surname = params[:surname].strip
  @email = params[:email].strip
   @city = params[:city].strip
  @address = params[:address].strip
  @twitter=params[:twitter].strip
  @password = params[:password].strip
  @confirm_password = params[:confirm_password].strip



  @firstname_ok =!@firstname.nil? && @firstname != ""
  @surname_ok = !@surname.nil? && @surname != ""
  @address_ok = !@address.nil? && @address != ""
  @email_ok = !@email.nil? && @email =~ VALID_EMAIL_REGEX

  @check_emails=@db.execute('SELECT * FROM customer WHERE email = ?LIMIT 1 ',[@email])
  @different_emails_ok=@check_emails[0].nil? || @check_emails[0]==""

  exists_ok=true

  begin
    exists= ch_twitter.user(@twitter)
  rescue Twitter::Error=> err
   exists_ok=false
  end


  @twitter_ok =!@twitter.nil? && exists_ok

  @check_twitter=@db.execute('SELECT * FROM customer WHERE twitterAcc = ?LIMIT 1 ',[@twitter])
  @different_twitter_ok=@check_twitter[0].nil? || @check_twitter[0]==""

  @password_ok = !@password.nil? && @password !="" && @password.length>=6
  @confirm_password_ok =  @confirm_password==@password

  @all_ok = @firstname_ok && @surname_ok &&@address_ok && @email_ok&& @password_ok&& @confirm_password_ok &&@different_emails_ok&&@twitter_ok&&@different_twitter_ok


  if @submitted && @all_ok
    ch_twitter.follow(@twitter)
    Stats.increment 'registrations',@city
    @db.execute('INSERT INTO customer(firstname, surname, email,twitterAcc, password, city,address) VALUES(?, ?, ?, ?,?,?,?)', [@firstname, @surname, @email,@twitter, @password,@city, @address ])
  end

  erb :access
end
