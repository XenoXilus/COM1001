before do
  @db = SQLite3::Database.new './curry_house.sqlite'
  @competitions = @db.execute('SELECT * FROM competitions')
  @winners = Array.new(@competitions.size,nil)
  @competitions.each_with_index do |comp,i|
    expired = comp[7]
    id = comp[0]
    if expired==1
      @winners[i]=@db.execute('SELECT * FROM competition_winners WHERE competition_id = ?',id)

    end
  end
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

#todo unit testing
def future_date date,time
  cday = Time.now.day
  cmonth = Time.now.month
  cyear = Time.now.year
  ctime_hour = Time.now.hour
  ctime_min = Time.now.min

  date = date.split('-')
  day = date[2].to_i
  month = date[1].to_i
  year = date[0].to_i

  time = time.split(':')
  time_hour = time[0].to_i
  time_min = time[1].to_i

  if year < cyear
    return false
  elsif year== cyear
    if month<cmonth
      return false
    elsif month==cmonth
      if day<cday
        return false
      elsif day==cday
        if time_hour<ctime_hour
          return false
        elsif time_hour==ctime_hour
          if time_min<ctime_min
            return false
          end
        end
      end
    end
  end
  return true
end

post '/trigger_competition' do
  @valid_date = future_date(params[:date],params[:time])

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
    ch_twitter.update(@msg)
    tweet_id = ch_twitter.home_timeline().take(1)[0].id
    @db.execute('INSERT INTO competitions(msg,date,time,nwinners,cp_reward,tweet_id) VALUES(?,?,?,?,?,?)', [@msg,@date,@time,@nwinners,@cp_reward,tweet_id])
    @competitions.push(@db.get_first_row('SELECT * FROM competitions WHERE msg = ?',@msg))
  end

  erb :offers
end

get '/get_winners' do
  redirect '/' if !session[:admin]

  @competitions.each do |comp|
    date = comp[2]
    time = comp[3]
    expired = !future_date(date,time)
    got_winners = @db.get_first_value('SELECT COUNT(*) FROM competition_winners WHERE competition_id = ?',comp[0]) != 0

    if expired && !got_winners
      tweet_id = comp[6]
      @db.execute('UPDATE competitions SET expired = 1 WHERE tweet_id = ?',tweet_id)
      participants = ch_twitter.retweeters_of(tweet_id)
      followers = ch_twitter.followers()

      participants.each do |p|
        participants.delete(p) if !(followers.include? p)
      end

      nwinners = comp[4]
      if nwinners<participants.size
        winners = participants.sample(nwinners)
      else
        winners = participants
      end

      winners.each do |user|
        id = comp[0]
        cp = comp[5]
        code = (0...8).map {(65 + rand(26)).chr}.join
        @db.execute('INSERT INTO competition_winners(competition_id,twitter_user,cp,coupon_code) values(?,?,?,?)',[id,user.screen_name,cp,code])
        msg = "Congratulations #{user.name}. You have won a #{cp} CurryPound voucher card in our RT competition.Voucher code:#{code}. "
        msg+= 'To redeem your price go to our website and enter the voucher code in your account page. To do this you must be registered.'
        msg+= 'The code is not associated with you so feel free to gift the coupon to a friend.'
        ch_twitter.create_direct_message(user.screen_name,msg)
      end

    end
  end

  redirect '/offers'
end