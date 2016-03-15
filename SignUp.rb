require 'erb'
require 'sinatra'
require 'sqlite3'

include ERB::Util

before do
  @db = SQLite3::Database.new('curry_house.sqlite')
end

VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
VALID_TWITTER_REGEX =/\A_?[a-z]_?(?:[a-z0-9]_?)*\z/i
# other option    /^([a-z_?])+$/i
# other option /^[^0-9\s+](_?[a-z0-9]+_?)+$/i

get '/sign_up' do
  @submitted = false

  erb :signUpForm
end

post '/form_handler' do
  @submitted = true


  @firstname = params[:firstname].strip
  @surname = params[:surname].strip
  @email = params[:email].strip
  @twitter=params[:twitter].strip
  @password = params[:password].strip
  @confirm_password = params[:confirm_password].strip



  @firstname_ok =
      !@firstname.nil? && @firstname != ""
  @surname_ok = !
  @surname.nil? && @surname != ""

  @email_ok =
      !@email.nil? && @email =~ VALID_EMAIL_REGEX

  @check_emails=@db.execute('SELECT * FROM customer WHERE email = ?LIMIT 1 ',[@email])
  @different_emails_ok=@check_emails[0].nil? || @check_emails[0]==""

  @twitter_ok =
      !@twitter.nil? && @twitter =~ VALID_TWITTER_REGEX

  @check_twitter=@db.execute('SELECT * FROM customer WHERE twitterAcc = ?LIMIT 1 ',[@twitter])
  @different_twitter_ok=@check_twitter[0].nil? || @check_twitter[0]==""

  @password_ok =
      !@password.nil? && @password !="" && @password.length>=6
  @confirm_password_ok =
      @confirm_password==@password

  @all_ok = @firstname_ok && @surname_ok && @email_ok&& @password_ok&& @confirm_password_ok &&@different_emails_ok&&@twitter_ok&&@different_twitter_ok


  if @submitted && @all_ok
    @db.execute('INSERT INTO customer(firstname, surname, email,twitterAcc, password) VALUES(?, ?, ?, ?,?)', [@firstname, @surname, @email,@twitter, @password, ])
  end

  erb :signUpForm
end










