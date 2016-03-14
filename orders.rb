before do
  @caught_tweets = Array.new

end

get '/orders' do
  begin
    search_for_orders
  rescue Twitter::Error::TooManyRequests => err
    puts "TooManyRequests, try again in #{err.rate_limit.reset_in} seconds"
  end
  erb :orders
end