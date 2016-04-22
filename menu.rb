require 'sqlite3'
require 'sinatra'
require 'erb'

before do
  @db = SQLite3::Database.new './curry_house.sqlite'
	#todo get session location!
	session[:sheffield] = TRUE
	session[:birmingham] = TRUE
end

get '/menu' do
	if session[:birmingham]
    query = %{SELECT itemName, description, unitPrice, vegetarian, glutenFree
              FROM menu
              WHERE category = ? AND atBirm = 1 }
	else
		query = %{SELECT itemName, description, unitPrice, vegetarian, glutenFree
              FROM menu
              WHERE category = ? AND atSheff = 1 }
  end

  @starterResults = @db.execute query, 'starter'
  @mildResults = @db.execute query, 'mild'
  @hotResults = @db.execute query, 'hot'
  @riceResults = @db.execute query, 'rice'
  @sidesResults = @db.execute query, 'side'
  #todo create means of easily identifying (V) or (GF) asside from item name

  erb :menu
end