require 'twitter'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

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

#search for tweets in the timeline that include 'order' or 'cancel' command
def search_timeline
  tweets = $client.mentions_timeline()
  most_recent = tweets.take(10)
  new_orders = []
  most_recent.each do |tweet|
    valid_order = tweet.text.include?('order') && (@caught_tweets.nil? || (!@caught_tweets.nil? && !tweet_is_caught(tweet.id)))
    valid_cancellation = tweet.text.include?('cancel')&& !tweet.attrs[:user][:screen_name].equal?('curryhouse02')
    if valid_order || valid_cancellation
      new_orders.push tweet
    end
  end
  return new_orders
end

#Saves the order information to the database and tweets back to the customer.
def process_order tweet
  twitter_username = tweet.attrs[:user][:screen_name]
  account_registered = @db.get_first_value('SELECT COUNT(*) FROM customer WHERE twitterAcc=?',twitter_username)[0]==1 ? true : false
  order_text = tweet.text.partition('order')[2]
  valid_format =  (/[A-Za-z]/ =~ order_text).nil?

  if account_registered && valid_format
    items = order_text.gsub(/^\s+|\s+$/,'').split(/\s+/) #strip leading & trailing spaces and split into items
    sum = 0
    items.each do |item|
      max_id = @db.get_first_value 'SELECT max(id) FROM menu'
      cost = @db.get_first_value('SELECT unitPrice FROM menu WHERE id = ?',item)
      if !cost.nil?
        sum += cost
      end
    end
    puts "sum = #{sum}"
    sum=sum.round(2)
    new_balance = @db.get_first_value('SELECT balance FROM customer WHERE twitterAcc = ?',twitter_username)-sum


    order_id = @db.execute 'SELECT max(order_id) FROM tweets'
    order_id = order_id[0][0] + 1
    tweet_arr = [tweet.id,twitter_username,order_text,'Ordered',order_id,sum]

    if new_balance<0
      tweet_arr[3] = 'Unpaid'
      tweet_status_change(tweet_arr)
    else
      @db.execute('UPDATE customer SET balance = ? WHERE twitterAcc = ?', [new_balance,twitter_username])
      $client.favorite(tweet.id)
      $client.update("Hi @#{twitter_username}! Your order with ID:#{order_id} has been accepted. To cancel go to our website!", :in_reply_to_status_id => tweet.id)
    end

    @db.execute('INSERT INTO tweets(id,sender,text,status,order_id,sum) VALUES (?,?,?,?,?,?)',tweet_arr)
    @caught_tweets.push(tweet_arr)

  else
    $client.update("Hi @#{twitter_username}! You must be registered in our website to process you order.", :in_reply_to_status_id => tweet.id)
  end
end

def process_cancellation tweet
  order_id = tweet.text.partition('cancel')[2].to_i
  max_order_id = @db.get_first_value('SELECT max(order_id) FROM tweets')
  if order_id!=0 && (order_id<=max_order_id) #if valid cancel message
    tweet_info = @db.get_first_row('SELECT * FROM tweets WHERE order_id=?',[order_id])
    order_status = tweet_info[3]

    if !((order_status=='Canceled') || (order_status=='Delivering'))
      @db.execute('UPDATE tweets SET status = "Canceled" WHERE order_id = ?',[order_id])
      @caught_tweets[order_id-1][3] = 'Canceled'
      tweet_info = @db.get_first_row('SELECT * FROM tweets WHERE order_id=?',[order_id])
      tweet_status_change(tweet_info)
    elsif (order_status=='Delivering')
      sender = @db.execute('SELECT sender FROM tweets WHERE order_id=?',[order_id])[0][0]
      $client.update("@#{sender}: Unfortunately we cannot process your cancellation request as you order is already staged for delivery. Order ID:#{order_id}.")
    end
  end
end


def tweet_status_change(tweet_entry)
  msg = case tweet_entry[3]
          when 'Preparing'
            'Your order is now being prepared!'
          when 'Delivering'
            'Your order has been sent for delivery!'
          when 'Completed'
            'Thank for ordering from us!'
          when 'Canceled'
            'Your order has been successfully canceled!'
          when 'Unpaid'
            "We can't process your request since you don't have enough CurryPounds in your balance."
          else
            return
        end
  $client.update("@#{tweet_entry[1]}: #{msg} Order ID:#{tweet_entry[4]}.", :in_reply_to_status_id => tweet_entry[0])
end

def tweet_is_caught(id)
  @caught_tweets.each do |r|
    if r[0] == id
      return true
    end
  end
  return false
end

# def competition
#   client.update('RT & favorite to enter our prize draw to earn money off at the checkout! Only one lucky winner will be selected at random after XX hours!')
#   #get retweeters after XX hours - select one at random
# end
#
# def offers
#   rand_number = 1000 + Random.rand(8999)
#   discount = "CH#{rand_number}"
#   client.update("Use discount code : #{discount} for money off at the checkout!")
# end

init