before do
  #@caught_tweets = Array.new
  @db = SQLite3::Database.new './curry_house.sqlite'
  @caught_tweets = @db.execute('SELECT * FROM tweets')
  @valid_city = Array.new(@caught_tweets.size,true)
end

get '/orders' do
  if !session[:admin]
    redirect '/'
  end

  @sheff_orders = true
  @birm_orders = true

  @too_many_requests = false
  begin
    new_orders = search_timeline
    new_orders.each do |tweet|
      if tweet.text.include?('order')
        process_order tweet
      elsif tweet.text.include?('cancel')
        process_cancellation tweet
      end
    end
  rescue Twitter::Error::TooManyRequests => err
    @limit = err.rate_limit.reset_in
    @too_many_requests = true
    puts "TooManyRequests, try again in #{err.rate_limit.reset_in} seconds"
  end

  @caught_tweets = @db.execute('SELECT * FROM tweets')
  @valid_city = Array.new(@caught_tweets.size,true)

  erb :orders
end

post '/change_status' do
  @sheff_orders = true
  @birm_orders = true

  for i in 1..@caught_tweets.size do
    if params["status#{i}"]=="on"
      #update both db and array
      @db.execute('UPDATE tweets SET status = ? WHERE id = ?',[params[:change_to],@caught_tweets[i-1][0]])
      @caught_tweets[i-1][3] = params[:change_to]
      tweet_status_change(@caught_tweets[i-1])
    end
  end

  erb :orders
end

get '/sheffield_orders' do
  if !session[:admin]
    redirect '/'
  end
  @sheff_orders = true
  @birm_orders = false

  @caught_tweets = @db.execute('SELECT * FROM tweets WHERE city = "sheffield"')

  erb :orders
end

get '/birmingham_orders' do
  if !session[:admin]
    redirect '/'
  end
  @sheff_orders = false
  @birm_orders = true

  @caught_tweets = @db.execute('SELECT * FROM tweets WHERE city = "birmingham"')

  erb :orders
end

get '/customer_orders' do
  if !session[:logged_in] ||session[:admin]
    redirect '/'
  end

  erb :customer_orders
end

post '/cancel_orders' do
  for i in 1..@caught_tweets.size do
    if params["status#{i}"]=="on"
      @db.execute('UPDATE tweets SET status = ? WHERE id = ?',['Canceled',@caught_tweets[i-1][0]])
      @caught_tweets[i-1][3] = 'Canceled'
    end
  end
  erb :customer_orders
end