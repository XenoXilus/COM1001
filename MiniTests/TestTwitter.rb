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

  def test_search_timeline
    set_up

    rand_item = (0...8).map { (65 + rand(26)).chr }.join
    #valid order
    $customer.update("@#{$ch_username} order #{rand_item}")
    sent_tweet = $customer.user_timeline("#{$customer_username}").take(1)[0]
    new_orders = search_timeline
    assert_includes new_orders,sent_tweet

    #valid order format with no recipient
    $customer.update("order #{rand_item}")
    sent_tweet = $customer.user_timeline("#{$customer_username}").take(1)[0]
    new_orders = search_timeline
    refute_includes new_orders,sent_tweet

    #valid cancellation
    $customer.update("@#{$ch_username} cancel #{Random.rand(100)}")
    new_orders = search_timeline
    sent_tweet = $customer.user_timeline("#{$customer_username}").take(1)[0]
    assert_includes new_orders,sent_tweet

    #cancellation with false/missing recipient
    $customer.update("cancel #{Random.rand(100)}")
    new_orders = search_timeline
    sent_tweet = $customer.user_timeline("#{$customer_username}").take(1)[0]
    refute_includes new_orders,sent_tweet

    #invalid format with recipient
    $customer.update("@#{$ch_username} ord #{rand_item}")
    new_orders = search_timeline
    sent_tweet = $customer.user_timeline("#{$customer_username}").take(1)[0]
    refute_includes new_orders,sent_tweet
  end

  def test_process_order
    set_up

    #valid order
    rand_item = (0...8).map { (65 + rand(26)).chr }.join
    $customer.update("@#{$ch_username} order #{rand_item}")
    tweet = $customer.user_timeline("#{$customer_username}").take(1)[0]
    process_order tweet
    assert_equal 1,$db.get_first_value('SELECT COUNT(*) FROM tweets WHERE id = ?',tweet.id)

    order_id = $db.get_first_value 'SELECT max(order_id) FROM tweets'
    expected_reply = "Hi @#{$customer_username}! Your order with ID:#{order_id} has been accepted. To cancel go to our website!"
    actual_reply = $customer.user_timeline("#{$ch_username}").take(1)[0].text
    assert_equal expected_reply,actual_reply

    #unregistered user
    rand_item = (0...8).map { (65 + rand(26)).chr }.join
    $customer.update("@#{$ch_username} order #{rand_item}")
    tweet = $customer.user_timeline("#{$customer_username}").take(1)[0]
    tweet.attrs[:user][:screen_name] = 'UnRegisteredUser'
    process_order tweet
    assert_equal 0,$db.get_first_value('SELECT COUNT(*) FROM tweets WHERE id = ?',tweet.id)

    expected_reply = 'Hi @UnRegisteredUser! You must be registered in our website to process you order.'
    actual_reply = $customer.user_timeline("#{$ch_username}").take(1)[0].text
    assert_equal expected_reply,actual_reply

  end

  def test_process_cancellation
    set_up

    #succesful cancellation
    customer_orders = $db.get_first_row('SELECT order_id FROM tweets WHERE sender = ? AND (status <> ? AND status <> ?)',[$customer_username,'Canceled','Delivering'])
    order_id = customer_orders[0]
    $customer.update("@#{$ch_username} cancel #{order_id}")
    tweet = $customer.user_timeline("#{$customer_username}").take(1)[0]
    process_cancellation tweet

    status = $db.get_first_value('SELECT status FROM tweets WHERE order_id = ?', [order_id])
    assert_equal 'Canceled', status

    expected_reply = "@#{$customer_username}: Your order has been successfully canceled! Order ID:#{order_id}."
    actual_reply = $customer.user_timeline("#{$ch_username}").take(1)[0].text
    assert_equal expected_reply,actual_reply

    #--------------------------
    #order status is 'Delivering'
    order_id = $db.get_first_value('SELECT max(order_id) FROM tweets WHERE sender = ?',[$customer_username])
    #order_id = orders.sample()[4]
    puts "order_id = #{order_id}"
    $db.execute('UPDATE tweets SET status = "Delivering" WHERE order_id = ?',order_id)

    $customer.update("@#{$ch_username} cancel #{order_id}")
    tweet = $customer.user_timeline("#{$customer_username}").take(1)[0]
    puts "tweet_text = #{tweet.text}"
    process_cancellation tweet

    status = $db.get_first_value('SELECT status FROM tweets WHERE order_id = ?', [order_id])
    assert_equal 'Delivering', status

    expected_reply = "@#{$customer_username}: Unfortunately we cannot process your cancellation request as you order is already staged for delivery. Order ID:#{order_id}."
    actual_reply = $customer.mentions_timeline().take(1)[0].text
    assert_equal expected_reply,actual_reply

    #--------------------------
    #order status is 'Canceled'
    orders = $db.execute('SELECT * FROM tweets WHERE sender = ?',[$customer_username])
    order_id = orders.sample()[4]
    $db.execute('UPDATE tweets SET status = "Canceled" WHERE order_id = ?',order_id)

    $customer.update("@#{$ch_username} cancel #{order_id}")
    tweet = $customer.user_timeline("#{$customer_username}").take(1)[0]
    process_cancellation tweet

    status = $db.get_first_value('SELECT status FROM tweets WHERE order_id = ?', [order_id])
    assert_equal 'Canceled', status

    unexpected_reply = "@#{$customer_username}: Your order has been successfully canceled! Order ID:#{order_id}."
    actual_reply = $customer.user_timeline("#{$ch_username}").take(1)[0].text
    refute_equal unexpected_reply,actual_reply

  end

  def test_tweet_status_change
    set_up

    order_id = $db.get_first_value 'SELECT max(order_id) FROM tweets'
    tweet_info = @db.get_first_row('SELECT * FROM tweets WHERE order_id=?',[Random.rand(order_id)+1])
    status_arr = ['Preparing','Delivering','Completed','Canceled']

    status_arr.each do |new_status|
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
              else
                return
            end

      tweet_status_change(tweet_info)

      expected = "@#{tweet_info[1]}: #{msg} Order ID:#{tweet_info[4]}."
      actual = $customer.mentions_timeline.take(1)[0].text
      assert_equal expected, actual
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