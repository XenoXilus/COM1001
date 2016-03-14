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

desc 'Display the contents of a table in a given database'
task :displaydb, [:database,:table] do|t,args|
  db = SQLite3::Database.new("./#{args[:database]}.sqlite")
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

