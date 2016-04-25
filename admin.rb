require 'sqlite3'
require 'sinatra'
require 'erb'
require_relative 'Stats'


before do
  @db = SQLite3::Database.new './curry_house.sqlite'
end

get '/admin' do
  if !session[:admin]
    redirect '/'
  end
  @page_header = 'Dashboard'

  erb :admin_panel
end

get '/admin_edit_menu' do
    query = %{SELECT id, itemName, description, unitPrice
                 FROM menu
                 WHERE category = ? }

    @starterResults = @db.execute query, 'starter'
    @mildResults = @db.execute query, 'mild'
    @hotResults = @db.execute query, 'hot'
    @riceResults = @db.execute query, 'rice'
    @sidesResults = @db.execute query, 'side'
    #todo create means of easily identifying (V) or (GF) asside from item name
    erb :dashboard_edit_menu
end

get '/stats' do
  if !session[:admin]
    redirect '/'
  end

  @nreg_users = @db.get_first_value('SELECT COUNT(*) FROM customer')
  # @norders = @db.get_first_value('SELECT FROM stats')
  # @norders = @db.get_first_value('SELECT FROM stats')
  #statistics = Stats.new
  @popular_item = Stats.get_popular_item

  erb :stats
end
get '/testing' do
	erb :narrow
end
