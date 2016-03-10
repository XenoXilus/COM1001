require 'sqlite3'

@db = SQLite3::Database.new './curry_house.sqlite'

sidesQuery = %{SELECT itemName, unitPrice, description FROM menu WHERE category = 'side'}
@sidesResults = @db.execute sidesQuery
puts @sidesResults

