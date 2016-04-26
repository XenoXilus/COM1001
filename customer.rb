before do
  @db = SQLite3::Database.new './curry_house.sqlite'
end

get '/customer_info' do
  if !session[:admin]
    redirect '/'
  end

  erb :customer_info
end

post '/search_customer' do
  @customer_twitter = params[:twitter_acc].strip
  puts "twitter = #{@customer_twitter}"
  session[:current_customer] = @customer_twitter
  @name = @db.get_first_value('SELECT firstName FROM customer WHERE twitterAcc = ?',@customer_twitter)
  @customer_found = true #tbc

  erb :customer_info
end

post '/blacklist_customer' do
  #@twitter_acc = params[:twitteracc].strip
  puts "ta = #{session[:current_customer]}"
  @db.execute('UPDATE customer SET blacklisted = 1 WHERE twitterAcc = ?', session[:current_customer])

  erb :customer_info
end