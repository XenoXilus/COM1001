before do
  @db = SQLite3::Database.new './curry_house.sqlite'
end

get '/customer_info' do
  if !session[:admin]
    redirect '/'
  end
  @submitted=false
  erb :customer_info
end

post '/search_customer' do
  @submitted=true
  @customer_twitter = params[:twitter_acc].strip
  session[:current_customer] = @customer_twitter



  @name = @db.get_first_value('SELECT firstname FROM customer WHERE twitterAcc = ?',@customer_twitter)
  @customer_found =!@name.nil?
  if @customer_found

    @surname=@db.get_first_value('SELECT surname FROM customer WHERE twitterAcc = ?',@customer_twitter)
    @address=@db.get_first_value('SELECT address FROM customer WHERE twitterAcc = ?',@customer_twitter)
    @email=@db.get_first_value('SELECT email FROM customer WHERE twitterAcc = ?',@customer_twitter)
    @city=@db.get_first_value('SELECT city FROM customer WHERE twitterAcc = ?',@customer_twitter)


  end


  erb :customer_info

end



post '/blacklist_customer' do
  #@twitter_acc = params[:twitteracc].strip
  puts "ta = #{session[:current_customer]}"
  @db.execute('UPDATE customer SET blacklisted = 1 WHERE twitterAcc = ?', session[:current_customer])

  erb :customer_info
end