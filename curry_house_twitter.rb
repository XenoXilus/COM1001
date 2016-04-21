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
  #curryhouse02
  config = {
      :consumer_key => 'NNtgfDPbs3e2RfYogLwozovGn',
      :consumer_secret => 'rZAtPRt3IlTJ0gUjMALihOYbDCqytVhse58lGPgn863gq5oLss',
      :access_token => '705790849393758208-DkouWibaCQ6xfnjygbm78Gfh9HxA1uB',
      :access_token_secret => 'ZJGwvPMmkwV5f6YaVZrUVgztiGcV1iXupncKGmqhXKXWb'
  }

  $client = Twitter::REST::Client.new(config)


  @db = SQLite3::Database.new './curry_house.sqlite'
  @caught_tweets = @db.execute('SELECT * FROM tweets')
end

def search_for_orders
  tweets = $client.mentions_timeline()
  most_recent = tweets.take(10)

  most_recent.each do |tweet|
    if !tweet.text.include? 'cancel'
      if tweet.text.include?('order') && (@caught_tweets.nil? || (!@caught_tweets.nil? && !array_has_id(@caught_tweets,tweet.id)))
        #new order processing

        twitter_username = tweet.attrs[:user][:screen_name]
        account_registered = @db.get_first_value('SELECT COUNT(*) FROM customer WHERE twitterAcc=?',twitter_username)[0]==1 ? true : false

        if account_registered
          order_id = @db.execute 'SELECT max(order_id) FROM tweets'
          order_id = order_id[0][0] + 1
          tweet_arr = [tweet.id,tweet.attrs[:user][:screen_name],tweet.text,'Ordered',order_id]
          puts "orders id = #{tweet_arr[4]}"
          @db.execute('INSERT INTO tweets(id,sender,text,status,order_id) VALUES (?,?,?,?,?)',tweet_arr)
          @caught_tweets.push(tweet_arr)

          $client.favorite(tweet.id)
          $client.update("Hi @#{twitter_username}! Your order with ID:#{order_id} has been accepted. To cancel go to our website!", :in_reply_to_status_id => tweet.id)
        else
          $client.update("Hi @#{twitter_username}! You must be registered in our website to process you order.", :in_reply_to_status_id => tweet.id)
        end

      end
    elsif tweet.text.include?('cancel') && !tweet.attrs[:user][:screen_name].equal?('curryhouse02')
      #puts "tweet msg: #{tweet.text}"
      order_id = tweet.text.partition('cancel')[2].to_i
      #puts "Order id: #{order_id}"

      if order_id!=0 #if valid cancel message
        tweet_info = @db.get_first_row('SELECT * FROM tweets WHERE order_id=?',[order_id])
        order_status = tweet_info[3]

        #puts "twitter_info: #{tweet_info}"
        #puts "order_status: #{order_status}"
        if !((order_status=='Canceled') || (order_status=='Delivering'))
          @db.execute('UPDATE tweets SET status = "Canceled" WHERE order_id = ?',[order_id])
          @caught_tweets[order_id-1][3] = 'Canceled'
          tweet_info = @db.get_first_row('SELECT * FROM tweets WHERE order_id=?',[order_id])
          tweet_status_change(tweet_info)
        elsif (order_status=='Delivering')
          sender = @db.execute('SELECT sender FROM tweets WHERE order_id=?',[order_id])[0][0]
          $client.update("@#{sender}: Unfortunately we cannot process your cancellation request as you order is already staged for delivery")
        end
      end
    end
  end
end

# def proccess_order
#
# end


def tweet_status_change(tweet)

  msg = case tweet[3]
          when 'Preparing'
            'Your order is now being prepared!'
          when 'Delivering'
            'Your order has been sent for delivery!'
          when 'Completed'
            'Thank for ordering from us!'
          when 'Canceled'
            'Your order has been successfully canceled!'
          else
            return
        end
  $client.update("@#{tweet[1]}: #{msg} Order ID:#{tweet[4]}.")#, :in_reply_to_status_id => tweet[0])
end

def array_has_id(arr,elem)
  arr.each do |r|
    if r[0] == elem
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