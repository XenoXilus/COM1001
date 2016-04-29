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
    query = %{SELECT id, itemName, description, unitPrice, vegetarian, glutenFree, atSheff, atBirm
                 FROM menu
                 WHERE category = ? }
    @starterResults = @db.execute query, 'starter'
    @mildResults = @db.execute query, 'mild'
    @hotResults = @db.execute query, 'hot'
    @riceResults = @db.execute query, 'rice'
    @sidesResults = @db.execute query, 'side'

    erb :dashboard_edit_menu
end

post '/delete_menu' do
    menuID = params[:menuID]
    if !menuID
        redirect '/admin'
    else
        executeDeleteQuery = @db.execute('DELETE FROM menu WHERE id = ?',[menuID])
        redirect '/admin_edit_menu'
    end

end

post '/add_menu' do
    @dishType = params[:dishType].strip
    @dishName = params[:dishName].strip
    @dishCost = params[:dishCost].strip
    @dishDesc = params[:dishDesc].strip
    @dishExtra = params[:dishExtraInfo].strip
    @dishAvailability = params[:dishAvailability].strip
    @confirmation = params[:dishConfirmation]

    dishType_ok = !@dishType.nil?
    dishName_ok = !@dishName.nil? && @dishName != ""
    dishCost_ok = !@dishCost.nil? && @dishCost != ""
    dishDesc_ok = !@dishDesc.nil? && @dishDesc != ""
    dishExtra_ok = !@dishExtra.nil? && @dishExtra != ""
    dishAvail_ok  = !@dishAvailability.nil? && @dishAvailability != ""
    confirmation_ok = !@confirmation.nil?

    all_ok = dishType_ok && dishName_ok && dishCost_ok && dishDesc_ok && confirmation_ok && dishExtra_ok && dishAvail_ok

    if all_ok
        case @dishExtra
        when "v"
            vegetarian = 1
            glutenFree = 0
        when "gf"
            vegetarian = 0
            glutenFree = 1
        else
            vegetarian = 1
            glutenFree = 1
        end

        case @dishAvailability
        when "sh"
            atSheff = 1
            atBirm = 0
        when "bi"
            atSheff = 0
            atBirm = 1
        else
            atSheff = 1
            atBirm = 1
        end
        executeAddQuery = @db.execute('INSERT INTO menu (itemName, unitPrice, description, category, vegetarian, glutenFree, atBirm, atSheff)
            VALUES (?,?,?,?,?,?,?,?)',[@dishName,@dishCost,@dishDesc,@dishType,vegetarian,glutenFree,atSheff,atBirm])
        redirect '/admin_edit_menu'
    end
end

post '/update_menu' do
    @dishID = params[:dishID]
    @dishName = params[:dishName].strip
    @dishCost = params[:dishCost].strip
    @dishDesc = params[:dishDesc].strip
    @gFree = params[:gFree]
    @dishVeggie = params[:dishVeggie]
    @atSheff = params[:atSheff]
    @atBirm = params[:atBirm]

    dishName_ok = !@dishName.nil? && @dishName != ""
    dishCost_ok = !@dishCost.nil? && @dishCost != ""
    dishDesc_ok = !@dishDesc.nil? && @dishDesc != ""
    gFree_ok = @gFree_ok == "1"|| @gFree_ok.nil?
    dishVeggie_ok = @dishVeggie == "1" || @dishVeggie.nil?
    atSheff_ok = @atSheff == "1" || @atSheff.nil?
    atBirm_ok = @atBirm == "1" || @atBirm.nil?

    if @gFree.nil?
        @gFree == "0"
    end
    if @dishVeggie.nil?
        @dishVeggie == "0"
    end
    if @atSheff.nil?
        @atSheff == "0"
    end
    if @atBirm.nil?
        @atBirm == "0"
    end

    all_ok = dishName_ok && dishCost_ok && dishDesc_ok && gFree_ok && dishVeggie_ok && atSheff_ok && atBirm_ok

    if all_ok
        exe = @db.execute('UPDATE menu SET itemName = ?, unitPrice = ?, description= ?, vegetarian = ?, glutenFree = ?, atBirm = ?, atSheff = ?
            WHERE id = ?',[@dishName,@dishCost,@dishDesc,@dishVeggie,@gFree,@atBirm,@atSheff,@dishID])
        redirect '/admin_edit_menu'
    end

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
