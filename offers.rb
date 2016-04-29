before do
  @db = SQLite3::Database.new './curry_house.sqlite'
end

get '/offers' do
  redirect '/' if !session[:admin]

  @norders = @db.get_first_value('SELECT norders FROM loyalty_offer')
  @cp = @db.get_first_value('SELECT cp FROM loyalty_offer')
  erb :offers
end

post '/set_offer' do
  @norders = params[:norders]
  @cp = params[:cp]
  @db.execute("UPDATE loyalty_offer SET norders = #{@norders}")
  @db.execute("UPDATE loyalty_offer SET cp = #{@cp}")

  redirect '/offers'
end