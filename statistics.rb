require_relative 'Stats'

before do
  @db = SQLite3::Database.new './curry_house.sqlite'
end

get '/stats' do
  redirect '/' if !session[:admin]

  @city = 'all'
  @sheff_stats = true
  @birm_stats = true

  @nreg_users = @db.get_first_value('SELECT COUNT(*) FROM customer')
  @total_norders = @db.get_first_value('SELECT COUNT(*) FROM tweets')

  erb :stats
end

get '/sheffield_stats' do
  redirect '/' if !session[:admin]

  @city = 'sheffield'
  @sheff_stats = true
  @birm_stats = false

  @nreg_users = @db.get_first_value('SELECT COUNT(*) FROM customer WHERE city = "sheffield"')
  @total_norders = 0
  orders = @db.execute('SELECT sender FROM tweets')
  orders.each do |sender|
    @total_norders+=1 if (@db.get_first_value('SELECT city FROM customer WHERE twitterAcc = ?',sender[0]).eql? 'sheffield')
  end

  erb :stats
end

get '/birmingham_stats' do
  redirect '/' if !session[:admin]

  @city = 'birmingham'
  @sheff_stats = false
  @birm_stats = true

  @nreg_users = @db.get_first_value('SELECT COUNT(*) FROM customer WHERE city = "birmingham"')
  @total_norders = 0
  orders = @db.execute('SELECT sender FROM tweets')
  orders.each do |sender|
    @total_norders+=1 if (@db.get_first_value('SELECT city FROM customer WHERE twitterAcc = ?',sender[0]).eql? 'birmingham')
  end

  erb :stats
end