class Stats
  # todo unit test
  @db = SQLite3::Database.new './curry_house.sqlite'
  @date = Time.now.strftime("%d/%m/%Y")

  def self.increment type
    has_day = @db.get_first_value('SELECT COUNT(*) FROM daily_stats WHERE date = ?',@date)
    if has_day==0
      @db.execute("INSERT INTO daily_stats(date,#{type}) VALUES(?,1)" ,[@date])
    else
      new_value = @db.get_first_value("SELECT #{type} FROM daily_stats WHERE date = ?",[@date]).to_i + 1
      info = @db.table_info('daily_stats')
      puts info
      @db.execute("UPDATE daily_stats SET #{type} = ? WHERE date = ?",[new_value,@date])
    end
  end

  def self.get type
    has_day = @db.get_first_value('SELECT COUNT(*) FROM daily_stats WHERE date = ?',@date)
    if has_day==0
      @db.execute('INSERT INTO daily_stats(date) VALUES(?)' ,[@date])
      return 0
    else
      return @db.get_first_value("SELECT #{type} FROM daily_stats WHERE date = ?",[@date]).to_i
    end
  end

  def self.get_avg type
    count = @db.get_first_value('SELECT COUNT(*) FROM daily_stats')
    sum = @db.get_first_value("SELECT SUM(#{type}) FROM daily_stats")
    if count!=0
      return sum/count
    else
      return 0
    end
  end

  def self.get_popular_item
    orders = @db.execute('SELECT text FROM tweets')

    max_id = @db.get_first_value('SELECT max(order_id) FROM tweets')
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

  def self.get_avg_cost
    count = @db.get_first_value('SELECT COUNT(*) FROM tweets WHERE (status <> "Canceled") AND (status <> "Unpaid")')
    sum = @db.get_first_value('SELECT SUM(sum) FROM tweets WHERE (status <> "Canceled") AND (status <> "Unpaid")')
    if count!=0
      return sum/count
    else
      return 0
    end
  end

end