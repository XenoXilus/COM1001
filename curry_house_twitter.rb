require 'twitter'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# tweets = client.search('curry house')
# most_recent = tweets.take(15)
# most_recent.each do |tweet|
#   if tweet.lang == 'en'
#     if !tweet.text.include? 'RT'
#       puts "Tweet #{tweet.id}: #{tweet.text}"
#       client.favorite(tweet.id)
#     end
#   end
# end

def init
  config = {
      :consumer_key => 'NNtgfDPbs3e2RfYogLwozovGn',
      :consumer_secret => 'rZAtPRt3IlTJ0gUjMALihOYbDCqytVhse58lGPgn863gq5oLss',
      :access_token => '705790849393758208-DkouWibaCQ6xfnjygbm78Gfh9HxA1uB',
      :access_token_secret => 'ZJGwvPMmkwV5f6YaVZrUVgztiGcV1iXupncKGmqhXKXWb'
  }

  $client = Twitter::REST::Client.new(config)
end

def search_for_orders


  tweets = $client.mentions_timeline()
  most_recent = tweets.take(5)



  #array_has_on_col(@caught_tweets,123,0)
  most_recent.each do |tweet|
    if !tweet.text.include? 'RT'
      if tweet.text.include?('order') && (@caught_tweets.nil? || (!@caught_tweets.nil? && !array_has_on_col(@caught_tweets,tweet.id,0)))
        puts "Order: #{tweet.text}"
        client.favorite(tweet.id)
        tweet_arr = [tweet.id,tweet.attrs[:user][:screen_name],tweet.text,'Ordered']
        @db.execute('INSERT INTO tweets VALUES (?,?,?,?)',tweet_arr)
        @caught_tweets.push(tweet_arr)
        client.update("Hi @#{tweet.attrs[:user][:screen_name]}! Your order has been accepted. To cancel go to our website!", :in_reply_to_status_id => tweet.id)
      end
    end
  end
end

def array_has_on_col(arr,elem,c)
  arr.each do |r|
    if r[c] == elem
      return true
    end
  end
  return false
end

def competition
  client.update('RT & favorite to enter our prize draw to earn money off at the checkout! Only one lucky winner will be selected at random after XX hours!')
  #get retweeters after XX hours - select one at random
end

def offers
  rand_number = 1000 + Random.rand(8999)
  discount = "CH#{rand_number}"
  client.update("Use discount code : #{discount} for money off at the checkout!")
end

init