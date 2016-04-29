before do
  @db = SQLite3::Database.new './curry_house.sqlite'
  @competitions = @db.execute('SELECT * FROM competitions')
end

get '/offers' do
  redirect '/' if !session[:admin]

  @norders = @db.get_first_value('SELECT norders FROM loyalty_offer')
  @cp = @db.get_first_value('SELECT cp FROM loyalty_offer')

  @date = Time.now.strftime("%Y/%m/%d").gsub('/','-')
  @time = '21:00'
  @nwinners = 1
  @cp_reward = 5
  @valid_msg =true
  @valid_date =true
  erb :offers
end

post '/set_offer' do
  @norders = params[:norders]
  @cp = params[:cp]
  @db.execute("UPDATE loyalty_offer SET norders = #{@norders}")
  @db.execute("UPDATE loyalty_offer SET cp = #{@cp}")

  redirect '/offers'
end

post '/trigger_competition' do
  #date/time validation
  cday = Time.now.day
  cmonth = Time.now.month
  cyear = Time.now.year
  ctime_hour = Time.now.hour
  ctime_min = Time.now.min

  date = params[:date].split('-')
  day = date[2].to_i
  month = date[1].to_i
  year = date[0].to_i
  @valid_date = true

  time = params[:time].split(':')
  time_hour = time[0].to_i
  time_min = time[1].to_i

  if year < cyear
    @valid_date = false
  elsif year== cyear
    if month<cmonth
      @valid_date = false
    elsif month==cmonth
      if day<cday
        @valid_date = false
      elsif day==cday
        if time_hour<ctime_hour
          @valid_date = false
        elsif time_hour==ctime_hour
          if time_min<ctime_min
            @valid_date= false
          end
        end
      end
    end
  end

  puts params

  @msg = params[:msg].strip
  if (@msg.nil?) || (@msg.eql? '')
    @valid_msg = false
  else
    @valid_msg = true
  end
  @date = params[:date]
  @time = params[:time]
  @nwinners = params[:nwinners]
  @cp_reward = params[:cp_reward]

  @valid = @valid_msg && @valid_date

  if @valid
    @db.execute('INSERT INTO competitions(msg,date,time,nwinners,cp_reward) VALUES(?,?,?,?,?)', [@msg,@date,@time,@nwinners,@cp_reward])
    ch_twitter.update(@msg)
    @competitions.push(@db.get_first_row('SELECT * FROM competitions WHERE msg = ?',@msg))
  end
  erb :offers
end