require 'sqlite3'
require 'sinatra'
require 'erb'

before do
  @db = SQLite3::Database.new './curry_house.sqlite'
end

get '/menu' do
  redirect '/' if session[:city].nil?
	if session[:city].eql? 'birmingham'
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

  @req_orders = @db.get_first_value('SELECT norders FROM loyalty_offer')
  @cp = @db.get_first_value('SELECT cp FROM loyalty_offer')

  erb :menu
end