before do
  @customer_info = SQLite3::Database.new './curry_house.sqlite'
  @redeeming = false
end

def get_info
  @results = @customer_info.get_first_row('SELECT * FROM customer WHERE twitterAcc = ?',session[:twitter_acc])
  if !@results.nil?
    @twitter_acc = @results[0]
    @cc_no = @results[1]
    @address = @results[2]
    @first_name = @results[5]
    @surname = @results[6]
    @atSheffield = @customer_info.get_first_value('SELECT city FROM customer WHERE twitterAcc = ?', @twitter_acc).downcase.eql? 'sheffield'
  end
end

get '/account' do
  if !session[:logged_in]
    redirect '/'
  end

  get_info

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
  @city = params[:city].strip

  @cc_no_ok = (@cc_no.nil? || @cc_no=="") || (@cc_no.length==16 && @cc_no.to_i.to_s == @cc_no)
  @first_name_ok = !@first_name.nil? && @first_name != ''
  @surname_ok = !@surname.nil? && @surname != ''
  @all_ok = @cc_no_ok && @first_name_ok && @surname_ok

  if @all_ok
    query = 'UPDATE customer SET cc=?, address=?, firstName=?, surname=?, city=? WHERE twitterAcc = ?'
    @customer_info.execute(query, [@cc_no,@address,@first_name,@surname,@city,session[:twitter_acc]])
  end

  erb :account
end

post '/update_balance' do
  @updating_balance = true
  get_info
  @has_cc = @cc_no!='' && !@cc_no.nil?

  if @has_cc
    old_balance = @customer_info.get_first_value('SELECT balance FROM customer WHERE twitterAcc = ?', session[:twitter_acc])
    @added_funds = params[:amount].to_i
    new_balance = old_balance.to_i+ @added_funds
    @customer_info.execute('UPDATE customer SET balance = ? WHERE twitterAcc = ?',[new_balance,session[:twitter_acc]])
  end

  erb :account
end

post '/redeem_voucher' do
  @redeeming = true

  code = params[:code].strip
  @exists = @customer_info.get_first_value('SELECT COUNT(*) FROM competition_winners WHERE coupon_code = ?',code) !=0
  @redeemed = (@customer_info.get_first_value('SELECT redeemed FROM competition_winners WHERE coupon_code = ?',code) ==1) if @exists
  if @exists && !@redeemed
    reward = @customer_info.get_first_value('SELECT cp FROM competition_winners WHERE coupon_code = ?',code)
    @added_funds = reward
    new_balance = @customer_info.get_first_value('SELECT balance FROM customer WHERE twitterAcc = ?', session[:twitter_acc]) + reward

    @customer_info.execute('UPDATE customer SET balance = ? WHERE twitterAcc = ?',[new_balance,session[:twitter_acc]])
    @customer_info.execute('UPDATE competition_winners SET redeemed = 1 WHERE coupon_code = ?',code)
    @succ_red = true
  else
    @succ_red = false
  end

  get_info
  erb :account
end