require 'erb'
require 'sinatra'
require 'sqlite3'

include ERB::Util

before do
  @db = SQLite3::Database.new('curry_house.sqlite')
end

VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

get '/' do
  @submitted = false
  erb :signUpForm
end

post '/form_handler' do
  @submitted = true
  @email_address = params[:email_address].strip

  @firstname = params[:firstname].strip
  @surname = params[:surname].strip
  @email_address = params[:email_address].strip
  @password = params[:password].strip
  @confirm_password = params[:confirm_password].strip


  @firstname_ok =
      !@firstname.nil? && @firstname != ""
  @surname_ok = !
  @surname.nil? && @surname != ""

  @email_address_ok =
      !@email_address.nil? && @email_address =~ VALID_EMAIL_REGEX

    @check_emails=@db.execute('SELECT*FROM Info WHERE Email_address = ?LIMIT 1 ',[@email_address])
  @different_emails_ok=@check_emails[0].nil? || @check_emails[0]==""

  @password_ok =
      !@password.nil? && @password !="" && @password.length>=6
  @confirm_password_ok =
      @confirm_password==@password

  @all_ok = @firstname_ok && @surname_ok && @email_address_ok&& @password_ok&& @confirm_password_ok &&@different_emails_ok


  if @submitted && @all_ok
    @db.execute('INSERT INTO Info VALUES(?, ?, ?, ?)', [@firstname, @surname, @email_address, @password])
end
  erb :signUpForm
end










