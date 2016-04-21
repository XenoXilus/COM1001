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


  def test_search_for_successful_order
    set_up

    $customer.update("@#{$ch_username} order #{(0...8).map { (65 + rand(26)).chr }.join}")
    search_for_orders
    tweet = $customer.mentions_timeline
    reply = tweet.take(1)[0]

    order_id = $db.get_first_value('SELECT max(order_id) FROM tweets')
    assert_equal "Hi @#{$customer_username}! Your order with ID:#{order_id} has been accepted. To cancel go to our website!", reply.text
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

  def test_search_for_orders_successful_cancelation
    set_up
    customer_orders = $db.execute("SELECT order_id FROM tweets WHERE sender = ? AND (status <> ? AND status <> ?)",[$customer_username,'Canceled','Delivering'])
    order_id = customer_orders.sample()[0]
    $customer.update("@#{$ch_username} cancel #{order_id}")

    search_for_orders
    actual_status = $db.get_first_value("SELECT status FROM tweets WHERE order_id = ?", [order_id])

    assert_equal 'Canceled', actual_status

  end


end