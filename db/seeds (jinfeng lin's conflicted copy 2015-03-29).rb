require './models/user'
require './models/tweet'
require './models/followee'
require 'csv'
require './server'

filename = './db/users.csv'
file = File.new(filename, 'r')

file.each_line("\n") do |row|
  columns = row.split(",")
  puts columns[1]
 end

file = File.new("./users.csv")
file.each_line("\n") do |row|
    columns = row.split(",")
    user_name = columns[1]
    email = user_name+"@email.com"
    password = "1234"
    Service.register(user_name, password, email)
end

#File.open("./db/users.csv").readlines.each do |line|
    #CSV.parse do |line|
    #    user_id, user_name = line 
    #    email = user_name+"@email.com"
    #    password = "1234"
    #    Service.register(user_name, password, email)
    #end
#end

#File.open("./db/follows.csv").readlines.each do |line|
#  CSV.parse do |line|
#    user_id, follower = line
#    Follow.create(user_id: user_id, follower: follower)   
#  end
#end

config.active_record.record_timestamps = false
filename = './db/tweets.csv'
file = File.new(filename, 'r')

file.each_line("\n") do |row|
  columns = row.split(",")
  user_id= columns[0]
  text=columns[1]
  time=columns[2]
  Tweet.create(text: text,user_id: user_id,created_at: time,updated_at: time)
  break if file.lineno > 10
 end



#File.open("./db/tweets.csv").readlines.each do |line|
#  CSV.parse do |line|
#    user_id,text, time = line
#    Tweet.create(text: text,user_id: user_id,created_at: time,updated_at: time)
#  end
#end





