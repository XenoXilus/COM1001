
before do
  @db = SQLite3::Database.new('curry_house.sqlite')
end

VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

get '/signup' do
  @submitted = false
  erb :signUpForm
end

post '/form_handler' do
  @submitted = true

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
  @password_ok =
      !@password.nil? && @password !="" && @password.length>=6
  @confirm_password_ok =
      @confirm_password==@password

  @all_ok = @firstname_ok && @surname_ok && @email_address_ok&& @password_ok&& @confirm_password_ok



  if @submitted && @all_ok
    @db.execute('INSERT INTO Info VALUES(?, ?, ?, ?)', [@firstname, @surname, @email_address, @password])

@check_email="not_same"

  @check_emails=@db.execute('SELECT * FROM Info WHERE Email_address=? LIMIT 1 '),[@email_address]

  puts @check_email
end
  erb :signUpForm
end










