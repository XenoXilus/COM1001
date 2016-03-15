before do
  #@caught_tweets = Array.new
  @db = SQLite3::Database.new './curry_house.sqlite'
  @caught_tweets = @db.execute('SELECT * FROM tweets')
end

get '/orders' do
  if !session[:admin]
    redirect '/'
  end

  begin
    search_for_orders
  rescue Twitter::Error::TooManyRequests => err
    puts "TooManyRequests, try again in #{err.rate_limit.reset_in} seconds"
  end

  erb :orders
end

post '/change_status' do
  for i in 0..@caught_tweets.size-1 do
    if params["status#{i}"]=="on"
      #update both db and array
      @db.execute('UPDATE tweets SET status = ? WHERE id = ?',[params[:change_to],@caught_tweets[i][0]])
      @caught_tweets[i][3] = params[:change_to]
      tweet_status_change(@caught_tweets[i])
    end
  end

  erb :orders
end