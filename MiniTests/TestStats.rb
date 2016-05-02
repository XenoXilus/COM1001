require 'sqlite3'
require 'minitest/autorun'
require_relative '../Stats.rb'

class TestStats < Minitest::Test
  def get_db
    db = SQLite3::Database.new './curry_house.sqlite'
    return db
  end
  def get_date
    return Time.now.strftime("%d/%m/%Y")
  end
  def delete_day
    date = get_date
    db = get_db
    db.execute('DELETE FROM daily_stats WHERE date = ? AND city = "sheffield"',date)
    db.execute('DELETE FROM daily_stats WHERE date = ? AND city = "birmingham"',date)
  end
  def reset_day
    date=get_date
    db = get_db
    delete_day
    db.execute('INSERT INTO daily_stats(date,city) VALUES(?,"sheffield")',date)
    db.execute('INSERT INTO daily_stats(date,city) VALUES(?,"birmingham")',date)

  end

  def test_increment
    db = get_db
    date = get_date
    reset_day
    types = ['orders','logins','registrations','cancellations','total_visits']
    types.each do |type|

      nSheff = rand(1..10)
      nBirm = rand(1..10)
      puts "Incrementing #{type} for sheffield #{nSheff+1} times"
      (0..nSheff).each do
        Stats.increment type,'sheffield'
      end
      puts "Incrementing #{type} for birmingham #{nBirm+1} times"
      (0..nBirm).each do
        Stats.increment type,'birmingham'
      end

      assert_equal nSheff+1,db.get_first_value("SELECT #{type} FROM daily_stats WHERE date = ? AND city = ?",[date,'sheffield'])
      assert_equal nBirm+1,db.get_first_value("SELECT #{type} FROM daily_stats WHERE date = ? AND city = ?",[date,'birmingham'])
    end
  end

  def test_get
    delete_day
    #get returns 0 when no entry for the day is made
    assert_equal 0,Stats.get('orders','sheffield')
    assert_equal 0,Stats.get('logins','birmingham')

    puts 'Testing for 0 values'
    reset_day
    types = ['orders','logins','registrations','cancellations','total_visits']
    types.each {|t| assert_equal(0,Stats.get(t,'sheffield'))}
    types.each {|t| assert_equal(0,Stats.get(t,'birmingham'))}
    types.each {|t| assert_equal(0,Stats.get(t,'all'))}

    db = get_db
    types.each do |t|
      nSheff = rand(10)
      nBirm = rand(10)
      puts "Testing #{t} for nSheff=#{nSheff}, nBirm=#{nBirm}"

      db.execute("UPDATE daily_stats SET #{t} = #{nSheff} WHERE city = 'sheffield'")
      db.execute("UPDATE daily_stats SET #{t} = #{nBirm} WHERE city = 'birmingham'")
      assert_equal nSheff,Stats.get(t,'sheffield')
      assert_equal nBirm,Stats.get(t,'birmingham')
      assert_equal (nSheff+nBirm),Stats.get(t,'all')
    end

  end

  def test_get_avg

    types = ['orders','logins','registrations','cancellations','total_visits']

    db = get_db
    types.each do |t|
      puts "Testing #{t} avg"

      sumS = db.get_first_value("SELECT SUM(#{t}) FROM daily_stats WHERE city = ?",'sheffield')
      sumB = db.get_first_value("SELECT SUM(#{t}) FROM daily_stats WHERE city = ?",'birmingham')
      sCount = db.get_first_value('SELECT COUNT(*) FROM daily_stats WHERE city = "sheffield"')
      bCount = db.get_first_value('SELECT COUNT(*) FROM daily_stats WHERE city = "birmingham"')
      assert_in_delta sumS/sCount,Stats.get_avg(t,'sheffield'),0.01
      assert_in_delta sumB/bCount,Stats.get_avg(t,'birmingham'),0.01
      assert_in_delta (sumS+sumB)/(sCount+bCount),Stats.get_avg(t,'all'),0.01
    end
  end

  def test_get_popular_item
    puts 'Testing get_popular item'
    db = get_db
    nOrders = db.get_first_value('SELECT COUNT(*) FROM tweets')

    puts 'Ensuring item 3 is popular for Sheffield'
    (1..nOrders).each  do
      id = db.get_first_value('SELECT max(id) FROM tweets')+1
      db.execute('INSERT INTO tweets(id,text,city) VALUES(?,"3 3 3","sheffield")',id)
    end
    puts 'Ensuring item 4 is popular for Birmingham'
    (1..nOrders).each  do
      id = db.get_first_value('SELECT max(id) FROM tweets')+1
      db.execute('INSERT INTO tweets(id,text,city) VALUES(?,"4 4 4","birmingham")',id)
    end

    assert_equal 3,Stats.get_popular_item('sheffield')
    assert_equal 4,Stats.get_popular_item('birmingham')
    assert_includes [3,4],Stats.get_popular_item('all')

    db.execute('DELETE FROM tweets WHERE text = "3 3 3" OR text = "4 4 4"')
  end

  def test_cost

    db = get_db
    db.execute('DELETE FROM tweets WHERE status = "Completed"')

    assert_equal 0,Stats.get_total_cost('sheffield')
    assert_equal 0,Stats.get_total_cost('birmingham')
    assert_equal 0,Stats.get_total_cost('all')

    assert_equal 0,Stats.get_total_cost('sheffield')
    assert_equal 0,Stats.get_total_cost('birmingham')
    assert_equal 0,Stats.get_total_cost('all')

    (1..3).each do |i|
      id = db.get_first_value('SELECT max(id) FROM tweets')+1
      db.execute('INSERT INTO tweets(id,text,city,sum,status) VALUES(?,"test","sheffield",?,"Completed")',[id,i])
      db.execute('INSERT INTO tweets(id,text,city,sum,status) VALUES(?,"test","birmingham",?,"Completed")',[id+1,i*2])
    end

    puts 'Testing get_total_cost'
    assert_in_delta (1+2+3),Stats.get_total_cost('sheffield'),0.001
    assert_in_delta (2+4+6),Stats.get_total_cost('birmingham'),0.001
    assert_in_delta (1+2+3+2+4+6),Stats.get_total_cost('all'),0.001

    puts 'Testing get_avg_cost'
    assert_in_delta (1+2+3)/3,Stats.get_avg_cost('sheffield'),0.001
    assert_in_delta (2+4+6)/3,Stats.get_avg_cost('birmingham'),0.001
    assert_in_delta (1+2+3+2+4+6)/6,Stats.get_avg_cost('all'),0.001

    db.execute('DELETE FROM tweets WHERE text = "test"')
  end

end