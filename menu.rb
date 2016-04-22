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

  @starterResults = @db.execute query, 'starter'
  @mildResults = @db.execute query, 'mild'
  @hotResults = @db.execute query, 'hot'
  @riceResults = @db.execute query, 'rice'
  @sidesResults = @db.execute query, 'side'
  #todo create means of easily identifying (V) or (GF) asside from item name

  erb :menu
end
