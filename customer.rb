before do
  #@db = SQLite3::Database.new './chinook.sqlite'
  @db = SQLite3::Database.new './customer_info.sqlite'
  @twitter_acc = 'OpioPellos'
end

get '/customer' do
  query = 'SELECT * FROM Customer WHERE TwitterAcc = ?'
  @results = @db.get_first_row(query,@twitter_acc)

  #@results = @db.execute "SELECT * FROM sqlite_master;"
  @results.each do |a|
    puts a
  end
  erb :customer
end

post '/update_info' do
  
end