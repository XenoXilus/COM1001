require 'erb'
require 'sinatra'
require 'sqlite3'
require 'twitter'


include ERB::Util

before do
  @db = SQLite3::Database.new('curry_house.sqlite')
end

VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i


config = {
    :consumer_key => 'NNtgfDPbs3e2RfYogLwozovGn',
    :consumer_secret => 'rZAtPRt3IlTJ0gUjMALihOYbDCqytVhse58lGPgn863gq5oLss',
    :access_token => '705790849393758208-DkouWibaCQ6xfnjygbm78Gfh9HxA1uB',
    :access_token_secret => 'ZJGwvPMmkwV5f6YaVZrUVgztiGcV1iXupncKGmqhXKXWb'
}

search = Twitter::REST::Client.new(config)


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



  @firstname_ok =!@firstname.nil? && @firstname != ""
  @surname_ok = !@surname.nil? && @surname != ""

  @email_ok = !@email.nil? && @email =~ VALID_EMAIL_REGEX

  @check_emails=@db.execute('SELECT * FROM customer WHERE email = ?LIMIT 1 ',[@email])
  @different_emails_ok=@check_emails[0].nil? || @check_emails[0]==""


  exists_ok=true

  begin
    exists= search.user(@twitter)
  rescue Twitter::Error::NotFound => err
   exists_ok=false
  end


  @twitter_ok =!@twitter.nil? && exists_ok

  @check_twitter=@db.execute('SELECT * FROM customer WHERE twitterAcc = ?LIMIT 1 ',[@twitter])
  @different_twitter_ok=@check_twitter[0].nil? || @check_twitter[0]==""

  @password_ok = !@password.nil? && @password !="" && @password.length>=6
  @confirm_password_ok =  @confirm_password==@password

  @all_ok = @firstname_ok && @surname_ok && @email_ok&& @password_ok&& @confirm_password_ok &&@different_emails_ok&&@twitter_ok&&@different_twitter_ok


  if @submitted && @all_ok
    @db.execute('INSERT INTO customer(firstname, surname, email,twitterAcc, password) VALUES(?, ?, ?, ?,?)', [@firstname, @surname, @email,@twitter, @password, ])
  end

  erb :signUpForm
end








