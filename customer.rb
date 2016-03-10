before do
  @customer_info = SQLite3::Database.new './curry_house.sqlite'
  @twitter_acc = 'OpioPellos'
end

#todo check change over of db still works
get '/customer' do
  @updating = false
  query = 'SELECT * FROM customer WHERE twitterAcc = ?'
  @results = @customer_info.get_first_row(query,@twitter_acc)

  @cc_no = @results[1]
  @address = @results[2]

  erb :customer
end

post '/update_info' do
  @updating = true

  query = 'SELECT * FROM customer WHERE twitterAcc = ?'
  @results = @customer_info.get_first_row(query,@twitter_acc)

  @cc_no =  params[:cc].strip
  @address = params[:address].strip

  @cc_no_ok = !@cc_no.nil? && @cc_no.length==16 && @cc_no.to_i.to_s == @cc_no
  @address_ok = !@address.nil? && @address != ''
  @all_ok = @cc_no_ok && @address_ok

  if @all_ok
    query = 'UPDATE customer SET cc=?, address=? WHERE twitterAcc = ?'
    @customer_info.execute(query, [@cc_no,@address,@twitter_acc])
  end
  erb :customer
end