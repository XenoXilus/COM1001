require 'sqlite3'

@db = SQLite3::Database.new './curry_house.sqlite'

query = %{SELECT itemName, description, unitPrice
               FROM menu
               WHERE category = ? }
@sidesResults = @db.execute query, 'side'