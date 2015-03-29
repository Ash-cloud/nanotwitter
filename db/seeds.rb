require './models/user'
require './models/tweet'
require './models/followee'
require 'csv'
require './server'


file = File.new("./db/users.csv")
file.each_line("\n") do |row|
    columns = row.split(",")
    user_name = columns[1].chomp
    email = user_name+"@email.com"
    password = "1234"
    Service.register(user_name, password, email)
     
end

filename = './db/follows.csv'
file = File.new(filename, 'r')

file.each_line("\n") do |row|
	columns = row.split(",")
	user_id=columns[0]
	follower=columns[1]
	Follow.create(user_id: user_id, follower: follower)

end

filename = './db/tweets.csv'
file = File.new(filename, 'r')

file.each_line("\n") do |row|
	columns = row.split(",",2)
	str = columns[1]
	str =~ /(.*):(.*)?/
	last_pos = str.rindex(/\,/)
	rest = [str[0..last_pos-1].strip, str[last_pos + 1 .. str.length].strip]

	user_id= columns[0]
	text=rest[0]
	time=rest[1]
	tweet=Tweet.create(text: text,user_id: user_id)
	tweet.update(created_at: time,updated_at: time)
	tweet_id= tweet[:id]
	Service.post_tweet_user(user_id,tweet_id)
	followers = Service.get_followers(user_id)
	
	followers.each do |follower|
		Service.post_tweet_user(follower[:follower],tweet_id)	
	end

 end





