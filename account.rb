before do
  @customer_info = SQLite3::Database.new './curry_house.sqlite'
  @results = @customer_info.get_first_row('SELECT * FROM customer WHERE email = ?',session[:email])#session[:@twitter_acc])
  puts "results = #{@results}"
  if !@results.nil?
    @twitter_acc = @results[0]
    @cc_no = @results[1]
    @address = @results[2]
    @first_name = @results[5]
    @surname = @results[6]
  end

end

get '/account' do

  @updating = false

  erb :account
end

post '/update_info' do
  @updating = true

  @cc_no =  params[:cc].strip
  @address = params[:address].strip
  @first_name = params[:first_name].strip
  @surname = params[:surname].strip

  @cc_no_ok = !@cc_no.nil? && @cc_no.length==16 && @cc_no.to_i.to_s == @cc_no
  @address_ok = !@address.nil? && @address != ''
  @first_name_ok = !@first_name.nil? && @first_name != ''
  @surname_ok = !@surname.nil? && @surname != ''
  @all_ok = @cc_no_ok && @address_ok && @first_name_ok && @surname_ok

  if @all_ok
    query = 'UPDATE customer SET cc=?, address=?, firstName=?, surname=? WHERE twitterAcc = ?'
    puts [@cc_no,@address,@twitter_acc,@first_name,@surname]
    @customer_info.execute(query, [@cc_no,@address,@first_name,@surname,@twitter_acc])
  end

  erb :account
end