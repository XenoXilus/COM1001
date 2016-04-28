require 'sqlite3'
require 'sinatra'
require 'erb'

before do
  @db = SQLite3::Database.new './curry_house.sqlite'

	#todo get session location elsewhere
	session[:sheffield] = TRUE
	session[:birmingham] = FALSE
end

get '/menu' do
	if session[:birmingham]
    query = %{SELECT itemName, description, unitPrice, vegetarian, glutenFree, id
              FROM menu
              WHERE category = ? AND atBirm = 1 }
	else
		query = %{SELECT itemName, description, unitPrice, vegetarian, glutenFree, id
              FROM menu
              WHERE category = ? AND atSheff = 1 }
  end

  @starterResults = @db.execute query, 'starter'
  @mildResults = @db.execute query, 'mild'
  @hotResults = @db.execute query, 'hot'
  @riceResults = @db.execute query, 'rice'
  @sidesResults = @db.execute query, 'side'

	Array @m = [
			["Starters", @starterResults],
	    ["Mild Dishes", @mildResults],
	    ["Hot Dishes", @hotResults],
	    ["Rice Dishes", @riceResults],
	    ["Sides", @sidesResults]
	]

  erb :menu
end