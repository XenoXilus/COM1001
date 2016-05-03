require 'rake/testtask'

require_relative 'app.rb'

desc 'Deletes all the records of a given .sqlite database'
task :wipedb, [:database] do |t,args|
  db = SQLite3::Database.new("./#{args[:database]}.sqlite")
  tb_names = db.execute("SELECT name FROM sqlite_master WHERE type='table'")
  tb_names.each do |tb|
    db.execute("DELETE FROM #{tb[0]}")
  end
end

desc 'Display the contents of a table in the database'
task :displaydb, [:table] do|t,args|
  db = SQLite3::Database.new('./curry_house.sqlite')
  results = db.execute("SELECT * FROM #{args[:table]}")

  table_info = db.execute("PRAGMA table_info(#{args[:table]})")

  for i in 0..results.size-1 do
    for j in 0..table_info.size-1 do
      puts "#{table_info[j][1]}: #{results[i][j]}"
    end
    puts
  end
end

desc "Display the contents of the session hash(can be used for debugging)"
task :display_session do
  puts session[:email]
end

desc "Run the Sinatra app locally"
task :run do
  Sinatra::Application.run!
end

def delete_all_tweets
  init

  tweets = $client.user_timeline('curryhouse02').take(20)
  while !tweets.empty?
    tweets.each do |tweet|
      if !tweet.nil?
        $client.destroy_status(tweet.id)
      end
    end
    tweets = $client.user_timeline('curryhouse02').take(20)
  end
end

desc 'Delete all tweets made by curryhouse02'
task :delete_tweets do
  delete_all_tweets
end

task :deploy do
  #Deleting db entries
  db = SQLite3::Database.new './curry_house.sqlite'
  tb_names = db.execute("SELECT name FROM sqlite_master WHERE type='table'")
  tb_names.each do |tb|
    db.execute("DELETE FROM #{tb[0]}")
  end

  #Inserting default admin account and setting loyalty offers to 0
  db.execute('INSERT INTO customer(twitterAcc,email,firstName,surName,password,city) VALUES("curryhouse02","admin@ch.com","Name","Surname","123456","sheffield")')
  db.execute('INSERT INTO administrators VALUES("admin@ch.com")')
  db.execute('INSERT INTO loyalty_offer VALUES(0,0)')


  #Reseting twitter account state(delete all tweets, unfollow following users & unfavorite all liked tweets)
  delete_all_tweets

  favorite_tweets = $client.favorites
  while !favorite_tweets.empty? do
    favorite_tweets.each {|t| $client.unfavorite(t.id)}
    favorite_tweets = $client.favorites
  end

  following = $client.following.take(20)
  while !following.empty? do
    following.each {|t| $client.unfollow(t.id)}
    following = $client.following.take(20)
  end

end