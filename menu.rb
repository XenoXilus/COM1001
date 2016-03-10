require 'sqlite3'
require 'sinatra'
require 'erb'

before do
  @db = SQLite3::Database.new './curry_house.sqlite'
end

get '/menu' do
  query = %{SELECT itemName, description, unitPrice
               FROM menu
               WHERE category = ? }

  @sidesResults = @db.execute query, 'side'
  @starterResults = @db.execute query, 'starter'
  @mildResults = @db.execute query, 'mild'
  @hotResults = @db.execute query, 'hot'

  erb :menu
end