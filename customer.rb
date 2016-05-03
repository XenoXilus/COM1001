before do
  @db = SQLite3::Database.new './curry_house.sqlite'
end

get '/customer_info' do
  redirect '/' if !session[:admin]

  @submitted=false
  erb :customer_info
end

get '/search_customer' do
  redirect '/' if !session[:admin]

  @submitted=true
  @input = params[:input].strip

  session[:current_customer] = @input
  @name = @db.get_first_value('SELECT firstname FROM customer WHERE twitterAcc = ?',@input)
  @customer_found_twitter =!@name.nil?
  @surname=@db.get_first_value('SELECT surname FROM customer WHERE email = ?',@input)
  @customer_found_email =!@surname.nil?

  @customer_found=@customer_found_twitter|| @customer_found_email


  if @customer_found

    if @customer_found_twitter
      @twitter=@input
      @email=@db.get_first_value('SELECT email FROM customer WHERE twitterAcc = ?',@input)
      @surname=@db.get_first_value('SELECT surname FROM customer WHERE twitterAcc = ?',@input)
      @address=@db.get_first_value('SELECT address FROM customer WHERE twitterAcc = ?',@input)
      @city=@db.get_first_value('SELECT city FROM customer WHERE twitterAcc = ?',@input)
      @balance=@db.get_first_value('SELECT balance FROM customer WHERE twitterAcc = ?',@input)
      cc=@db.get_first_value('SELECT cc FROM customer WHERE twitterAcc = ?',@input)
    else
      @twitter=@db.get_first_value('SELECT twitterAcc FROM customer WHERE email = ?',@input)
      @email=@input
      @name=@db.get_first_value('SELECT firstname FROM customer WHERE email = ?',@input)
      @address=@db.get_first_value('SELECT address FROM customer WHERE email = ?',@input)
      @city=@db.get_first_value('SELECT city FROM customer WHERE email = ?',@input)
      @balance=@db.get_first_value('SELECT balance FROM customer WHERE email = ?',@input)
      cc=@db.get_first_value('SELECT cc FROM customer WHERE email = ?',@input)
    end

    if !cc.nil? then
      @cCard="YES"
    else
      @cCard="NO"
    end

    session[:current_customer]=@twitter

    blacklisted = @db.get_first_value('SELECT blacklisted FROM customer WHERE twitterAcc = ?',session[:current_customer]) == 1
      @button_text = blacklisted ? 'Unblacklist' : 'Blacklist'

    admin_ok = !@db.get_first_value('SELECT email FROM administrators WHERE email = ?',@email).nil?
      @button2 = admin_ok ? 'Unmake administrator' : 'Make administrator'


  end

  erb :customer_info

end


get '/adminButton' do
  redirect '/' if !session[:admin]

  # count = db.execute('SELECT Count(*) FROM administrators')

  twitter_acc = session[:current_customer]

  email=@db.get_first_value('SELECT email FROM customer WHERE twitterAcc = ?',twitter_acc)

  admin_ok = !@db.get_first_value('SELECT email FROM administrators WHERE email = ?',email).nil?

  if admin_ok

    @db.execute('DELETE FROM administrators where email = ?',email)
  else
    @db.execute('INSERT INTO administrators(email) VALUES(?)',[email])
  end
  redirect "/search_customer?input=#{twitter_acc}"
end


get '/blacklistButton' do
  redirect '/' if !session[:admin]

  twitter_acc = session[:current_customer]
  blacklisted = @db.get_first_value('SELECT blacklisted FROM customer WHERE twitterAcc = ?',twitter_acc) == 1
  if blacklisted
    @db.execute('UPDATE customer SET blacklisted = 0 WHERE twitterAcc = ?', twitter_acc)
    ch_twitter.update("@#{twitter_acc} You have been unbanned from our website! Sorry for any inconvenience caused.")
  else
    @db.execute('UPDATE customer SET blacklisted = 1 WHERE twitterAcc = ?', twitter_acc)
    ch_twitter.update("@#{twitter_acc} We are sorry to inform you that your account has been banned from our website.")
  end
  redirect "/search_customer?input=#{twitter_acc}"
end