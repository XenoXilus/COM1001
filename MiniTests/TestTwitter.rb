require 'minitest/autorun'
require_relative '../app.rb'

class TestTwitter < Minitest::Test
  def set_up

    config = {
        :consumer_key => 'aLqE0P5k5kkBAOhtgVFCs5GK0',
        :consumer_secret => 'neLJBgq4uEd3s21hE4lSZEDAP46cJzgkmhqRAxzr3BphBjcC7w',
        :access_token => '248845175-FX1jPuSKmGuUxeS71B5sLGdvttjZ2OO6tk5pSilU',
        :access_token_secret => 'sI7Wgj0yF7bLQGdiPxaPGYUrt928hmCuCiQulrbsXls5v'
    }
    $customer = Twitter::REST::Client.new(config)
    $customer_username = 'Alexg7g7'
    $ch_username = 'curryhouse02'
    $db = SQLite3::Database.new './curry_house.sqlite'
    init

  end

  def new_tweet text
    set_up

    $customer.update(text)
    sent_tweet = $customer.user_timeline("#{$customer_username}").take(1)[0]
    return sent_tweet
  end

  #todo delete test tweets from database
  #todo add refund tests
  def test_search_timeline
    set_up

    positive_tests = ["@#{$ch_username} order 1 2 3", #valid order format
                      "@#{$ch_username} cancel 7"] #valid cancellation format

    negative_tests = ['order 1 5 6', #false/missing recipient
                     "@#{$ch_username} order 1 2 s 4", #order text has alphabetic characters
                     "@#{$ch_username} order ", #empty order text
                     "@#{$ch_username} ord 5 6 7", #unrecognised command
                     'cancel 5'] #false/missing recipient

    positive_tests.each do |text|
      puts "text = #{text}"
      sent_tweet = new_tweet(text)
      assert_includes search_timeline,sent_tweet
      $customer.destroy_status(sent_tweet.id)
    end

    negative_tests.each do |text|
      puts "text = #{text}"
      sent_tweet = new_tweet(text)
      refute_includes search_timeline,sent_tweet
      $customer.destroy_status(sent_tweet.id)
    end
  end

  def test_process_order
    set_up

    $db.execute('UPDATE customer SET address = "adr" WHERE twitterAcc =?',$customer_username)
    valid_orders = ["@#{$ch_username} order 1","@#{$ch_username} order 1 2 3"]
    items = [[1],[1,2,3]]

    valid_orders.each_with_index do |text,i|
      puts text
      #ensure there are enough CPs in the customer's balance
      $db.execute('UPDATE customer SET balance = 30 WHERE twitterAcc =?',$customer_username)

      #tweet is registered in the database
      tweet = new_tweet(text)
      process_order tweet
      assert_equal 1,$db.get_first_value('SELECT COUNT(*) FROM tweets WHERE id = ?',tweet.id)

      #a reply is received
      order_id = $db.get_first_value 'SELECT max(order_id) FROM tweets'
      expected_reply = "Hi @#{$customer_username}! Your order with ID:#{order_id} has been accepted. To cancel go to our website!"
      actual_reply = $customer.user_timeline("#{$ch_username}").take(1)[0]
      assert_equal expected_reply,actual_reply.text

      $customer.destroy_status(tweet.id)
      $client.destroy_status(actual_reply.id)

      #balance is reduced correctly
      sum=0
      items[i].each do |item|
        sum+=$db.get_first_value('SELECT SUM(unitPrice) FROM menu WHERE id=? OR id=? OR id=?',item)
      end
      exp_balance = 30-sum
      act_balance = $db.get_first_value('SELECT balance FROM customer WHERE twitterAcc =?',$customer_username)
      assert_equal exp_balance,act_balance
    end

    #----------------------
    #Not enough CurryPounds
    $db.execute('UPDATE customer SET balance = 0 WHERE twitterAcc =?',$customer_username)
    tweet = new_tweet("@#{$ch_username} order 1")
    process_order tweet

    #order is registered as unpaid
    assert_equal 1,$db.get_first_value('SELECT COUNT(*) FROM tweets WHERE id = ?',tweet.id)
    assert_equal 'Unpaid',$db.get_first_value('SELECT status FROM tweets WHERE id = ?',tweet.id)

    #a notification is received
    order_id = $db.get_first_value 'SELECT max(order_id) FROM tweets'
    expected_reply = "@#{$customer_username}: We can't process your request since you don't have enough CurryPounds in your balance. Order ID:#{order_id}."
    actual_reply = $customer.user_timeline("#{$ch_username}").take(1)[0]
    assert_equal expected_reply,actual_reply.text

    $customer.destroy_status(tweet.id)
    $client.destroy_status(actual_reply.id)

    #balance is still 0
    assert_equal 0,$db.get_first_value('SELECT balance FROM customer WHERE twitterAcc =?',$customer_username)

    #todo add tests for orders with 0 sum or invalid order ids

    #------------------
    #unregistered user
    tweet = new_tweet("@#{$ch_username} order 123")
    tweet.attrs[:user][:screen_name] = 'UnRegisteredUser'
    process_order tweet
    assert_equal 0,$db.get_first_value('SELECT COUNT(*) FROM tweets WHERE id = ?',tweet.id)

    expected_reply = 'Hi @UnRegisteredUser! You must have an address registered in our website to process you order.'
    actual_reply = $customer.user_timeline("#{$ch_username}").take(1)[0]
    assert_equal expected_reply,actual_reply.text

    $customer.destroy_status(tweet.id)
    $client.destroy_status(actual_reply.id)

    #no address
    $db.execute('UPDATE customer SET address = "" WHERE twitterAcc =?',$customer_username)
    tweet = new_tweet("@#{$ch_username} order 123")
    process_order tweet
    assert_equal 0,$db.get_first_value('SELECT COUNT(*) FROM tweets WHERE id = ?',tweet.id)
    expected_reply = "Hi @#{$customer_username}! You must have an address registered in our website to process you order."
    actual_reply = $customer.user_timeline("#{$ch_username}").take(1)[0]
    assert_equal expected_reply,actual_reply.text

    $customer.destroy_status(tweet.id)
    $client.destroy_status(actual_reply.id)

  end


  def test_process_cancellation
    set_up

    #Sucessful cancellations
    ['Ordered','Preparing','Unpaid','Canceled','Completed'].each do |os|
      puts "status is #{os}"
      order_id = $db.get_first_value('SELECT max(order_id) FROM tweets WHERE sender = ?',[$customer_username])
      $db.execute('UPDATE tweets SET status = ? WHERE order_id = ?',[os,order_id])
      tweet = new_tweet("@#{$ch_username} cancel #{order_id}")
      process_cancellation tweet

      status = $db.get_first_value('SELECT status FROM tweets WHERE order_id = ?', [order_id])
      expected_reply = "@#{$customer_username}: Your order has been successfully canceled! Order ID:#{order_id}."
      actual_reply = $customer.user_timeline("#{$ch_username}").take(1)[0]
      case os
        when 'Completed','Canceled' #status doesn't change and a reply is not received.
          assert_equal os, status
          refute_equal expected_reply,actual_reply.text
        when 'Delivering'
          assert_equal 'Delivering', status
          expected_reply = "@#{$customer_username}: Unfortunately we cannot process your cancellation request as you order is already staged for delivery. Order ID:#{order_id}."
          assert_equal expected_reply,actual_reply.text
        else
          assert_equal 'Canceled', status
          assert_equal expected_reply,actual_reply.text
      end

      $customer.destroy_status(tweet.id)
      $client.destroy_status(actual_reply.id)
    end

  end

  def test_tweet_status_change
    set_up

    order_id = $db.get_first_value 'SELECT max(order_id) FROM tweets'
    tweet_info = $db.get_first_row('SELECT * FROM tweets WHERE order_id=?',order_id)

    ['Preparing','Delivering','Completed','Canceled','Unpaid'].each do |new_status|
      puts "new status = #{new_status}"
      tweet_info[3] = new_status
      msg = case new_status
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
            end
      tweet_status_change(tweet_info)

      expected_reply = "@#{$customer_username}: #{msg} Order ID:#{order_id}."
      actual_reply = $customer.user_timeline($ch_username).take(1)[0]
      assert_equal expected_reply, actual_reply.text

      $client.destroy_status(actual_reply.id)
    end
  end

  def test_tweet_is_caught
    set_up

    orders = $db.get_first_row('SELECT * FROM tweets')
    id = orders[0]

    assert_equal true, tweet_is_caught(id)
    assert_equal false, tweet_is_caught(123)

  end

end