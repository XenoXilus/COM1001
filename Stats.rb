class Stats
  @db = SQLite3::Database.new './curry_house.sqlite'
  # def initialize
  #   @db = SQLite3::Database.new './curry_house.sqlite'
  # end
  def self.get_popular_item
    orders = @db.execute('SELECT text FROM tweets')

    max_id = @db.get_first_value('SELECT max(order_id) FROM tweets')
    count = Array.new(max_id+1, 0)
    orders.each do |order_text|
      puts "text = #{order_text}"
      items = order_text[0].gsub(/^\s+|\s+$/,'').split(/\s+/)
      puts items
      items.each do |item|
        if item.to_i<=max_id
          count[item.to_i]+=1
        end
      end

    end

    return count.find_index(count.max)
    # puts 'count:'
    # puts count
    # return count[1]
  end
end