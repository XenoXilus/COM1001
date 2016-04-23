before do
  @customer_info = SQLite3::Database.new './curry_house.sqlite'
  @results = @customer_info.get_first_row('SELECT * FROM customer WHERE email = ?',session[:email])#session[:@twitter_acc])
  #puts "results = #{@results}"
  if !@results.nil?
    @twitter_acc = @results[0]
    @cc_no = @results[1]
    @address = @results[2]
    @first_name = @results[5]
    @surname = @results[6]
  end

end

get '/account' do
  if !session[:logged_in]
    redirect '/'
  end
  @updating = false
  @updating_balance = false

  erb :account
end

post '/update_info' do
  @updating = true

  @cc_no =  params[:cc].strip
  @address = params[:address].strip
  @first_name = params[:first_name].strip
  @surname = params[:surname].strip

  @cc_no_ok = (@cc_no.nil? || @cc_no=="") || (@cc_no.length==16 && @cc_no.to_i.to_s == @cc_no)
  @first_name_ok = !@first_name.nil? && @first_name != ''
  @surname_ok = !@surname.nil? && @surname != ''
  @all_ok = @cc_no_ok && @first_name_ok && @surname_ok

  if @all_ok
    query = 'UPDATE customer SET cc=?, address=?, firstName=?, surname=? WHERE twitterAcc = ?'
    #puts [@cc_no,@address,@twitter_acc,@first_name,@surname]
    @customer_info.execute(query, [@cc_no,@address,@first_name,@surname,@twitter_acc])
  end

  erb :account
end

post '/update_balance' do
  @updating_balance = true
  @has_cc = @cc_no!='' && !@cc_no.nil?

  if @has_cc
    old_balance = @customer_info.get_first_value('SELECT balance FROM customer WHERE twitterAcc = ?', session[:twitter_acc])
    @added_funds = params[:amount].to_i
    new_balance = old_balance.to_i+ @added_funds
    @customer_info.execute('UPDATE customer SET balance = ? WHERE twitterAcc = ?',[new_balance,session[:twitter_acc]])
  end

  erb :account
end