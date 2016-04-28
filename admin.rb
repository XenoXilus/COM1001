require 'sqlite3'
require 'sinatra'
require 'erb'
require_relative 'Stats'
require_relative 'customer'


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

post '/delete_menu' do
    menuID = params[:menuID]
    if !menuID
        redirect '/admin'
    else
        executeDeleteQuery = @db.execute('DELETE FROM menu WHERE id = ?',[menuID])
    end

end

post '/add_menu' do
    @dishType = params[:dishType].strip
    @dishName = params[:dishName].strip
    @dishCost = params[:dishCost].strip
    @confirmation = params[:dishConfirmation]
    'hello'
    '#{@dishType} #{@dishName} #{@dishCost} #{@confirmation}'

    dishType_ok = !@dishType.nil?
    dishName_ok = !@dishName.nil? && @dishName != ""
    dishCost_ok = !@dishCost.nil? && @dishCost != ""
    #confirmation_ok

end

get '/stats' do
  if !session[:admin]
    redirect '/'
  end

  @nreg_users = @db.get_first_value('SELECT COUNT(*) FROM customer')
  @total_norders = @db.get_first_value('SELECT COUNT(*) FROM tweets')

  erb :stats
end

get '/testing' do
	erb :narrow
end
