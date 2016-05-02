class Stats
  # todo unit test
  @db = SQLite3::Database.new './curry_house.sqlite'
  @date = Time.now.strftime("%d/%m/%Y")

  def self.increment type, city
    has_day = @db.get_first_value('SELECT COUNT(*) FROM daily_stats WHERE date = ? AND city = ?',@date,city)
    if has_day==0
      @db.execute("INSERT INTO daily_stats(city,date,#{type}) VALUES(?,?,1)" ,[city,@date])
    else
      new_value = @db.get_first_value("SELECT #{type} FROM daily_stats WHERE date = ? AND city = ?",[@date,city]).to_i + 1
      @db.execute("UPDATE daily_stats SET #{type} = ? WHERE date = ? AND city = ?",[new_value,@date,city])
    end
  end

  def self.get type, city
    if city.eql? 'all'
      return Stats.get(type, 'sheffield') + Stats.get(type,'birmingham')
    end
    has_day = @db.get_first_value('SELECT COUNT(*) FROM daily_stats WHERE date = ? AND city=?',[@date,city])
    if has_day==0
      @db.execute('INSERT INTO daily_stats(city,date) VALUES(?,?)' ,[city,@date])
      return 0
    else
      return @db.get_first_value("SELECT #{type} FROM daily_stats WHERE date = ? AND city=?",[@date,city]).to_i
    end
  end

  def self.get_avg type, city
    if city.eql? 'all'
      count = @db.get_first_value('SELECT COUNT(*) FROM daily_stats')
      sum = @db.get_first_value("SELECT SUM(#{type}) FROM daily_stats")
      return count!=0 ? sum/count : 0
    end
    count = @db.get_first_value('SELECT COUNT(*) FROM daily_stats WHERE city = ? ',city)
    sum = @db.get_first_value("SELECT SUM(#{type}) FROM daily_stats WHERE city = ?",city)
    return count!=0 ? sum/count : 0
  end

  def self.get_popular_item city
    if city.eql? 'all'
      return [Stats.get_popular_item('sheffield'),Stats.get_popular_item('birmingham')].max
    end
    orders = @db.execute('SELECT text FROM tweets WHERE city = ?',city)

    max_id = @db.get_first_value('SELECT max(id) FROM menu')
    count = Array.new(max_id+1, 0)
    orders.each do |order_text|
      items = order_text[0].gsub(/^\s+|\s+$/,'').split(/\s+/)
      items.each do |item|
        if item.to_i<=max_id
          count[item.to_i]+=1
        end
      end
    end

    return count.find_index(count.max)
  end

  def self.get_total_cost city
    if city.eql? 'all'
      sum = @db.get_first_value('SELECT SUM(sum) FROM tweets WHERE status = "Completed"')
      return !sum.nil? ? sum : 0
    end
    sum = @db.get_first_value('SELECT SUM(sum) FROM tweets WHERE (city = ?) AND (status = "Completed")',city)
    return !sum.nil? ? sum : 0
  end

  def self.get_avg_cost city
    if city.eql? 'all'
      count = @db.get_first_value('SELECT COUNT(*) FROM tweets WHERE status = "Completed"')
    else
      count = @db.get_first_value('SELECT COUNT(*) FROM tweets WHERE (city = ?) AND (status = "Completed")',city)
    end
    sum = Stats.get_total_cost city
    return count!=0 ? sum/count : 0
  end

end